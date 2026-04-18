#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:?usage: validate-generated-docs.sh <directory>}"
ALLOW_LEGACY_LABELS="${PRD_GENERATOR_ALLOW_LEGACY_LABELS:-1}"
FAILED=0
SEP=$'\034'
EM_DASH="$(printf '\342\200\224')"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

normalize_expr() {
  printf '%s' "$1" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//; s/;$//; s/^\((.*)\)$/\1/'
}

trim_csv_field() {
  printf '%s' "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

require_heading() {
  local file="$1"
  local pattern="$2"
  if ! grep -Eq "$pattern" "$file"; then
    echo "missing required section [$pattern] in $file"
    FAILED=1
  fi
}

check_required_sections() {
  local file="$1"
  local basename
  basename="$(basename "$file")"

  case "$basename" in
    CLAUDE.md)
      require_heading "$file" '^## Hallucination Guardrail'
      require_heading "$file" '^## Reading Order'
      require_heading "$file" '^## Authority Hierarchy'
      require_heading "$file" '^## Maintenance Rules'
      grep -Eq '@docs/' "$file" || {
        echo "missing project-relative @docs reference in $file"
        FAILED=1
      }
      ;;
    AGENTS.md)
      require_heading "$file" '^## 1\. Mandatory Reading'
      require_heading "$file" '^## 3\. Core Rules'
      require_heading "$file" '^## .*Testing'
      ;;
    README.md)
      require_heading "$file" '^## Features'
      require_heading "$file" '^## Quick Start'
      require_heading "$file" '^## Project Structure'
      require_heading "$file" '^## Development'
      ;;
    CHANGELOG.md)
      require_heading "$file" '^# Changelog'
      ;;
    DEVELOPMENT-WORKFLOW.md)
      require_heading "$file" '^## 1\. Environment Setup'
      require_heading "$file" '^## 2\. Database Migrations'
      require_heading "$file" '^## .*Testing'
      require_heading "$file" '^## .*Branch & Commit Conventions'
      ;;
    api-docs.md)
      require_heading "$file" '^## Response Envelope'
      require_heading "$file" '^## Authentication'
      require_heading "$file" '^## Endpoint Groups'
      ;;
    api-endpoints.md)
      require_heading "$file" '^# API Endpoints Reference'
      require_heading "$file" '^# Confirmed Endpoints'
      require_heading "$file" '^# Proposed Endpoints'
      ;;
    api-models.md)
      require_heading "$file" '^## Confirmed Models'
      require_heading "$file" '^## Proposed Models'
      require_heading "$file" '^## Model Relationships'
      require_heading "$file" '^## RLS Policy Summary'
      ;;
    service-boundaries.md)
      require_heading "$file" '^## Domain Modules'
      require_heading "$file" '^## Ownership Boundaries'
      require_heading "$file" '^## Coupling to Avoid'
      require_heading "$file" '^## Decisions'
      ;;
    SUPABASE-PATTERNS.md)
      require_heading "$file" '^## RLS Policies'
      require_heading "$file" '^## RLS Lint Checklist'
      require_heading "$file" '^## Strict Transition Example'
      ;;
    *-prd-v*.md)
      require_heading "$file" '^## .*Overview'
      require_heading "$file" '^### .*Goals'
      require_heading "$file" '^### .*Non-Goals'
      require_heading "$file" '^## .*Resolved Decisions'
      require_heading "$file" '^## Implementation Readiness'
      require_heading "$file" '^### Safe to implement now'
      require_heading "$file" '^### Needs explicit decision before coding'
      require_heading "$file" '^### Needs decision before deployment \(non-blocking for coding\)'
      require_heading "$file" '^### Intentionally deferred from this version'
      ;;
  esac
}

check_empty_sections() {
  local file="$1"
  awk '
  function heading_level(line) {
    if (line ~ /^###[[:space:]]/) return 3
    if (line ~ /^##[[:space:]]/) return 2
    return 0
  }
  /^###[[:space:]]|^##[[:space:]]/ {
    new_level = heading_level($0)
    if (section != "" && !has_content) {
      if (!(section_level == 2 && new_level == 3)) {
        print "empty section in " FILENAME ": " section
        exit 1
      }
    }
    section=$0
    section_level=new_level
    has_content=0
    next
  }
  {
    if (section != "" && $0 !~ /^[[:space:]]*$/ && $0 !~ /^---$/ && $0 !~ /^<!--/ && $0 !~ /^```/) {
      has_content=1
    }
  }
  END {
    if (section != "" && !has_content) {
      print "empty final section in " FILENAME ": " section
      exit 1
    }
  }
  ' "$file" || FAILED=1
}

check_em_dash_in_prose() {
  local file="$1"
  if awk -v em_dash="$EM_DASH" '
    /^```/ { in_fence = !in_fence; next }
    in_fence { next }
    {
      line = $0
      gsub(/`[^`]*`/, "", line)
      if (index(line, em_dash) > 0) {
        print FILENAME ":" NR ": em dash in prose: " $0
        found = 1
      }
    }
    END { exit found }
  ' "$file"; then
    :
  else
    FAILED=1
  fi
}

check_placeholders() {
  local file="$1"
  if grep -Ein '\b(Lorem|foo bar)\b|TODO($|[^[:alpha:]])|example\.com' "$file"; then
    echo "placeholder found in $file"
    FAILED=1
  fi
}

check_label_shapes() {
  local file="$1"
  if awk -v allow_legacy="$ALLOW_LEGACY_LABELS" '
    /^```/ { in_fence = !in_fence; next }
    in_fence { next }
    {
      line = $0
      gsub(/`[^`]*`/, "", line)

      if (line ~ /^#/) {
        next
      }

      if (line ~ /TBD \{/ || line ~ /TBD \(reason:/ || index(line, ": TBD") > 0 || line ~ /^- TBD([[:space:]]|$)/) {
        if (line ~ /TBD \{ blocks_coding: (yes|no), reason: "[^"]+"(, default: "[^"]+")? \}/) {
          if (line ~ /blocks_coding: no/ && line !~ /default: "[^"]+"/) {
            print FILENAME ":" NR ": non-blocking TBD missing default: " $0
            failed = 1
          }
        } else if (line ~ /TBD \(reason: [^)]+\)/) {
          if (allow_legacy == 1) {
            next
          }
          print FILENAME ":" NR ": legacy TBD syntax missing classifier: " $0
          failed = 1
        } else {
          print FILENAME ":" NR ": invalid TBD shape: " $0
          failed = 1
        }
      }

      if (line ~ /Assumed \{/ || index(line, ": Assumed") > 0 || line ~ /^- Assumed([[:space:]]|$)/) {
        if (line !~ /Assumed \{ question: "[^"]+", default: "[^"]+", flip_cost: "(low|medium|high)" \}/) {
          print FILENAME ":" NR ": invalid Assumed shape: " $0
          failed = 1
        }
      }

      if (line ~ /Proposed \{/ || index(line, ": Proposed") > 0 || line ~ /^- Proposed([[:space:]]|$)/) {
        if (line !~ /Proposed \{ promote_when: "[^"]+" \}/) {
          print FILENAME ":" NR ": invalid Proposed shape: " $0
          failed = 1
        }
      }
    }
    END { exit failed }
  ' "$file"; then
    :
  else
    FAILED=1
  fi
}

check_version_currency() {
  local file="$1"

  if grep -Ein '\b(Node(\.js)?[[:space:]]*(20|21|22|23)(\.[0-9]+)?|node@(20|21|22|23)|nvm install[[:space:]]+(20|21|22|23)|FROM[[:space:]]+node:(20|21|22|23)|node:(20|21|22|23)|Next(\.js)?[[:space:]]*(14|15)(\.[0-9]+)?|nextjs[[:space:]]*(14|15)(\.[0-9]+)?)\b' "$file"; then
    echo "stale runtime/framework version found in $file"
    FAILED=1
  fi

  if awk '
    /^```/ { in_fence = !in_fence; next }
    in_fence { next }
    {
      line = $0
      gsub(/`[^`]*`/, "", line)
      low = tolower(line)

      if (low ~ /(node(\.js)?[[:space:]]*24|node[[:space:]]*24)/) {
        if (low !~ /latest lts/ && low !~ /latest stable/ && low !~ /pinned/ && low !~ /required for/ && low !~ /because/ && low !~ /due to/ && low !~ /reason:/) {
          print FILENAME ":" NR ": unlabeled current Node reference: " $0
          failed = 1
        }
      }

      if (low ~ /(next\.js[[:space:]]*16|nextjs[[:space:]]*16|next[[:space:]]*16)/) {
        if (low !~ /latest stable/ && low !~ /pinned/ && low !~ /required for/ && low !~ /because/ && low !~ /due to/ && low !~ /reason:/) {
          print FILENAME ":" NR ": unlabeled current Next.js reference: " $0
          failed = 1
        }
      }
    }
    END { exit failed }
  ' "$file"; then
    :
  else
    FAILED=1
  fi
}

parse_model_fields() {
  local file="$1"
  local out="$2"
  awk '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    /^## Confirmed Models/ { in_confirmed = 1; next }
    /^## Proposed Models/ { in_confirmed = 0 }
    /^## RLS Policy Summary/ { in_confirmed = 0 }
    in_confirmed && /^\|/ {
      split($0, parts, "|")
      field = trim(parts[2])
      if (field != "" && field != "Property" && field !~ /^-+$/) {
        print field
      }
    }
  ' "$file" | sort -u > "$out"
}

parse_model_policies() {
  local file="$1"
  local out="$2"
  awk -v sep="$SEP" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    function flush() {
      if (name != "") {
        print name sep table sep operation sep access sep using sep with_check sep enforced
      }
      name = table = operation = access = using = with_check = enforced = ""
    }
    /^### Policy `/ {
      flush()
      name = $0
      sub(/^### Policy `/, "", name)
      sub(/`$/, "", name)
      next
    }
    /^\*\*Table:\*\* `/ {
      table = $0
      sub(/^\*\*Table:\*\* `/, "", table)
      sub(/`$/, "", table)
      next
    }
    /^\*\*Operation:\*\* `/ {
      operation = $0
      sub(/^\*\*Operation:\*\* `/, "", operation)
      sub(/`$/, "", operation)
      next
    }
    /^\*\*Access summary:\*\* `/ {
      access = $0
      sub(/^\*\*Access summary:\*\* `/, "", access)
      sub(/`$/, "", access)
      next
    }
    /^\*\*USING:\*\* `/ {
      using = $0
      sub(/^\*\*USING:\*\* `/, "", using)
      sub(/`$/, "", using)
      next
    }
    /^\*\*WITH CHECK:\*\* `/ {
      with_check = $0
      sub(/^\*\*WITH CHECK:\*\* `/, "", with_check)
      sub(/`$/, "", with_check)
      next
    }
    /^\*\*Enforced by:\*\* `/ {
      enforced = $0
      sub(/^\*\*Enforced by:\*\* `/, "", enforced)
      sub(/`$/, "", enforced)
      next
    }
    END {
      flush()
    }
  ' "$file" | sort > "$out"
}

parse_endpoint_contracts() {
  local file="$1"
  local out="$2"
  awk -v sep="$SEP" '
    function flush() {
      if (endpoint != "") {
        print endpoint sep table sep policy sep access sep fields
      }
      endpoint = table = policy = access = fields = ""
    }
    /^### (GET|POST|PUT|PATCH|DELETE) \/api\/v[0-9.]+\// {
      flush()
      endpoint = $0
      sub(/^### /, "", endpoint)
      next
    }
    /^\*\*Table:\*\* `/ {
      table = $0
      sub(/^\*\*Table:\*\* `/, "", table)
      sub(/`$/, "", table)
      next
    }
    /^\*\*Governing policy:\*\* `/ {
      policy = $0
      sub(/^\*\*Governing policy:\*\* `/, "", policy)
      sub(/`$/, "", policy)
      next
    }
    /^\*\*Access summary:\*\* `/ {
      access = $0
      sub(/^\*\*Access summary:\*\* `/, "", access)
      sub(/`$/, "", access)
      next
    }
    /^\*\*Field contract:\*\* / {
      fields = $0
      sub(/^\*\*Field contract:\*\* /, "", fields)
      gsub(/`/, "", fields)
      next
    }
    END {
      flush()
    }
  ' "$file" | sort > "$out"
}

parse_workflow_refs() {
  local file="$1"
  local out="$2"
  awk -v sep="$SEP" '
    /^## .*Core Workflows/ { in_workflows = 1; next }
    in_workflows && /^## / { in_workflows = 0 }
    in_workflows && /^[0-9]+\./ {
      line = $0
      if (line !~ /`[^`]+`/) {
        print "__MISSING_REFERENCE__" sep NR sep $0
        next
      }
      while (match(line, /`[^`]+`/)) {
        ref = substr(line, RSTART + 1, RLENGTH - 2)
        if (ref !~ /^UI only/) {
          print ref sep NR sep $0
        }
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$file" > "$out"
}

parse_supabase_policies() {
  local file="$1"
  local out="$2"
  awk -v sep="$SEP" '
    function flush() {
      if (name != "") {
        print name sep operation sep access sep transition sep enforced sep using sep with_check
      }
      name = operation = access = transition = enforced = using = with_check = ""
    }
    /^```sql/ { in_sql = 1; next }
    in_sql && /^```/ { in_sql = 0; flush(); next }
    !in_sql { next }
    /^-- ACCESS:/ {
      pending_access = $0
      sub(/^-- ACCESS:[[:space:]]*/, "", pending_access)
      next
    }
    /^-- TRANSITION:/ {
      pending_transition = $0
      sub(/^-- TRANSITION:[[:space:]]*/, "", pending_transition)
      next
    }
    /^-- ENFORCED BY:/ {
      pending_enforced = $0
      sub(/^-- ENFORCED BY:[[:space:]]*/, "", pending_enforced)
      next
    }
    /^CREATE POLICY / {
      flush()
      name = $0
      sub(/^CREATE POLICY[[:space:]]+/, "", name)
      sub(/[[:space:]].*$/, "", name)
      access = pending_access
      transition = pending_transition
      enforced = pending_enforced
      pending_access = pending_transition = pending_enforced = ""
      next
    }
    name != "" && /FOR (SELECT|INSERT|UPDATE|DELETE) TO/ {
      operation = $0
      sub(/.*FOR[[:space:]]+/, "", operation)
      sub(/[[:space:]]+TO.*/, "", operation)
      next
    }
    name != "" && /USING \(/ {
      using = $0
      sub(/^[[:space:]]*USING[[:space:]]+/, "", using)
      sub(/;$/, "", using)
      next
    }
    name != "" && /WITH CHECK \(/ {
      with_check = $0
      sub(/^[[:space:]]*WITH CHECK[[:space:]]+/, "", with_check)
      sub(/;$/, "", with_check)
      next
    }
    END {
      if (in_sql) {
        flush()
      }
    }
  ' "$file" | sort > "$out"
}

check_policy_guard_reference() {
  local supabase_file="$1"
  local enforced="$2"
  local guard_name

  guard_name="$(printf '%s' "$enforced" | sed -E 's/^(trigger|function|helper)[[:space:]]+//')"

  if printf '%s' "$enforced" | grep -Eq '^trigger[[:space:]]+'; then
    grep -Eq "CREATE TRIGGER[[:space:]]+${guard_name}\b" "$supabase_file"
    return
  fi

  if printf '%s' "$enforced" | grep -Eq '^(function|helper)[[:space:]]+'; then
    grep -Eq "FUNCTION[[:space:]]+.*${guard_name}\b" "$supabase_file" && grep -Eq 'SECURITY DEFINER' "$supabase_file"
    return
  fi

  return 1
}

with_check_is_looser() {
  local using="$1"
  local with_check="$2"

  if printf '%s' "$with_check" | grep -Eq '[[:space:]]OR[[:space:]]'; then
    return 0
  fi

  if [ "$(normalize_expr "$using")" = "$(normalize_expr "$with_check")" ]; then
    return 0
  fi

  if printf '%s\n%s\n' "$using" "$with_check" | awk '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    NR == 1 { using = $0 }
    NR == 2 { with_check = $0 }
    END {
      split(using, using_parts, /AND/)
      for (i in using_parts) {
        part = trim(using_parts[i])
        if (part ~ /= auth.uid\(\)/ && index(with_check, part) == 0) {
          exit 0
        }
        if (part ~ /=/) {
          split(part, groups, "=")
          column = trim(groups[1])
          if (index(with_check, column " IN (") > 0 || index(with_check, column " IN(") > 0) {
            exit 0
          }
        }
      }
      exit 1
    }
  '; then
    return 0
  fi

  return 1
}

check_cross_doc_consistency() {
  local prd_file="$1"
  local endpoints_file="$2"
  local models_file="$3"
  local supabase_file="$4"
  local model_fields_file="$TMP_DIR/model-fields.tsv"
  local model_policies_file="$TMP_DIR/model-policies.tsv"
  local endpoint_contracts_file="$TMP_DIR/endpoint-contracts.tsv"
  local workflow_refs_file="$TMP_DIR/workflow-refs.tsv"
  local supabase_policies_file="$TMP_DIR/supabase-policies.tsv"

  parse_model_fields "$models_file" "$model_fields_file"
  parse_model_policies "$models_file" "$model_policies_file"
  parse_endpoint_contracts "$endpoints_file" "$endpoint_contracts_file"
  parse_workflow_refs "$prd_file" "$workflow_refs_file"
  parse_supabase_policies "$supabase_file" "$supabase_policies_file"

  while IFS="$SEP" read -r name table operation access using with_check enforced; do
    [ -n "$name" ] || continue

    local sql_row
    sql_row="$(grep -F "${name}${SEP}" "$supabase_policies_file" | head -n 1 || true)"
    if [ -z "$sql_row" ]; then
      echo "policy summary references missing SQL policy [$name] in $models_file"
      FAILED=1
      continue
    fi

    local sql_name sql_operation sql_access sql_transition sql_enforced sql_using sql_with_check
    IFS="$SEP" read -r sql_name sql_operation sql_access sql_transition sql_enforced sql_using sql_with_check <<EOF
$sql_row
EOF

    if [ -n "$operation" ] && [ "$(normalize_expr "$operation")" != "$(normalize_expr "$sql_operation")" ]; then
      echo "policy operation mismatch [$name]: models=$operation sql=$sql_operation"
      FAILED=1
    fi

    if [ -n "$using" ] && [ "$(normalize_expr "$using")" != "$(normalize_expr "$sql_using")" ]; then
      echo "policy USING mismatch [$name]: models=$using sql=$sql_using"
      FAILED=1
    fi

    if [ -n "$with_check" ] && [ "$(normalize_expr "$with_check")" != "$(normalize_expr "$sql_with_check")" ]; then
      echo "policy WITH CHECK mismatch [$name]: models=$with_check sql=$sql_with_check"
      FAILED=1
    fi
  done < "$model_policies_file"

  while IFS="$SEP" read -r endpoint table policy access fields; do
    [ -n "$endpoint" ] || continue

    if [ -z "$policy" ]; then
      echo "endpoint missing governing policy [$endpoint] in $endpoints_file"
      FAILED=1
      continue
    fi

    if printf '%s' "$policy" | grep -Eiq '^n/a'; then
      continue
    fi

    local model_row
    model_row="$(grep -F "${policy}${SEP}" "$model_policies_file" | head -n 1 || true)"
    if [ -z "$model_row" ]; then
      echo "endpoint references unknown policy [$policy] for [$endpoint]"
      FAILED=1
      continue
    fi

    local model_name model_table model_operation model_access model_using model_with_check model_enforced
    IFS="$SEP" read -r model_name model_table model_operation model_access model_using model_with_check model_enforced <<EOF
$model_row
EOF

    if [ -n "$access" ] && [ "$(normalize_expr "$access")" != "$(normalize_expr "$model_access")" ]; then
      echo "endpoint access summary mismatch [$endpoint]: endpoint=$access model=$model_access"
      FAILED=1
    fi

    if [ -n "$fields" ]; then
      OLDIFS="$IFS"
      IFS=','
      for raw_field in $fields; do
        local field
        field="$(trim_csv_field "$raw_field")"
        [ -n "$field" ] || continue
        if ! grep -Fxq "$field" "$model_fields_file"; then
          echo "endpoint field [$field] referenced by [$endpoint] is missing from $models_file"
          FAILED=1
        fi
      done
      IFS="$OLDIFS"
    fi
  done < "$endpoint_contracts_file"

  while IFS="$SEP" read -r reference line_number raw_line; do
    [ -n "$reference" ] || continue

    if [ "$reference" = "__MISSING_REFERENCE__" ]; then
      echo "$prd_file:$line_number: workflow step missing endpoint or UI-only marker: $raw_line"
      FAILED=1
      continue
    fi

    if ! cut -d "$SEP" -f 1 "$endpoint_contracts_file" | grep -Fxq "$reference"; then
      echo "$prd_file:$line_number: workflow reference [$reference] is not defined in $endpoints_file"
      FAILED=1
    fi
  done < "$workflow_refs_file"
}

check_rls_lint() {
  local models_file="$1"
  local supabase_file="$2"
  local model_policies_file="$TMP_DIR/rls-model-policies.tsv"
  local supabase_policies_file="$TMP_DIR/rls-supabase-policies.tsv"

  parse_model_policies "$models_file" "$model_policies_file"
  parse_supabase_policies "$supabase_file" "$supabase_policies_file"

  while IFS="$SEP" read -r name operation access transition enforced using with_check; do
    [ -n "$name" ] || continue

    if [ "$operation" != "UPDATE" ]; then
      continue
    fi

    if ! printf '%s' "$using" | grep -Fq 'auth.uid()'; then
      continue
    fi

    if [ -z "$transition" ]; then
      echo "non-admin update policy [$name] is missing a TRANSITION comment in $supabase_file"
      FAILED=1
    fi

    if [ -z "$with_check" ]; then
      echo "non-admin update policy [$name] is missing WITH CHECK in $supabase_file"
      FAILED=1
    elif with_check_is_looser "$using" "$with_check"; then
      echo "non-admin update policy [$name] has a loose WITH CHECK predicate in $supabase_file"
      FAILED=1
    fi

    local model_row
    model_row="$(grep -F "${name}${SEP}" "$model_policies_file" | head -n 1 || true)"
    if [ -z "$model_row" ]; then
      echo "missing api-models summary for update policy [$name]"
      FAILED=1
      continue
    fi

    local model_name model_table model_operation model_access model_using model_with_check model_enforced
    IFS="$SEP" read -r model_name model_table model_operation model_access model_using model_with_check model_enforced <<EOF
$model_row
EOF

    if [ -z "$enforced" ] && [ -z "$model_enforced" ]; then
      echo "non-admin update policy [$name] is missing ENFORCED BY metadata"
      FAILED=1
      continue
    fi

    local guard_ref
    guard_ref="${enforced:-$model_enforced}"
    if ! check_policy_guard_reference "$supabase_file" "$guard_ref"; then
      echo "non-admin update policy [$name] references guard [$guard_ref] but no matching trigger/helper was found"
      FAILED=1
    fi
  done < "$supabase_policies_file"
}

check_implementation_readiness() {
  local prd_file="$1"
  local blocking_count non_blocking_count deferred_count assumed_blocking_count
  blocking_count="$(grep -Ec 'TBD \{ blocks_coding: yes, reason: "[^"]+"' "$prd_file" || true)"
  non_blocking_count="$(grep -Ec 'TBD \{ blocks_coding: no, reason: "[^"]+", default: "[^"]+"' "$prd_file" || true)"
  assumed_blocking_count="$(grep -Ec 'Assumed \{ question: "[^"]+", default: "[^"]+", flip_cost: "(medium|high)" \}' "$prd_file" || true)"
  deferred_count="$(grep -Ec 'Proposed \{ promote_when: "[^"]*(vNext|defer)[^"]*" \}' "$prd_file" || true)"

  awk -v file="$prd_file" \
      -v blocking_count="$blocking_count" \
      -v non_blocking_count="$non_blocking_count" \
      -v assumed_blocking_count="$assumed_blocking_count" \
      -v deferred_count="$deferred_count" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    function flush() {
      if (section != "" && bullet_count == 0) {
        print "implementation readiness subsection is empty in " file ": " section
        failed = 1
      }
      if (section == "### Needs explicit decision before coding" && (blocking_count + assumed_blocking_count) > 0 && none_marker == 1) {
        print "blocking decisions exist but readiness section says none in " file
        failed = 1
      }
      if (section == "### Needs decision before deployment (non-blocking for coding)" && non_blocking_count > 0 && none_marker == 1) {
        print "non-blocking TBD items exist but readiness section says none in " file
        failed = 1
      }
      if (section == "### Intentionally deferred from this version" && deferred_count > 0 && none_marker == 1) {
        print "deferred Proposed items exist but readiness section says none in " file
        failed = 1
      }
      bullet_count = 0
      none_marker = 0
    }
    /^## Implementation Readiness/ { in_readiness = 1; next }
    in_readiness && /^## / {
      flush()
      in_readiness = 0
    }
    in_readiness && /^### / {
      flush()
      section = $0
      next
    }
    in_readiness && section != "" && /^- / {
      bullet_count++
      if ($0 !~ /\(source: [^)]+:[0-9]+\)/) {
        print "implementation readiness bullet missing source citation in " file ": " $0
        failed = 1
      }
      if ($0 ~ /^- None\./) {
        none_marker = 1
      }
      next
    }
    END {
      if (in_readiness) {
        flush()
      }
      exit failed
    }
  ' "$prd_file" || FAILED=1
}

while IFS= read -r file; do
  check_em_dash_in_prose "$file"
  check_placeholders "$file"
  check_label_shapes "$file"
  check_version_currency "$file"
  check_required_sections "$file"
  check_empty_sections "$file"
done < <(find "$TARGET_DIR" -type f -name '*.md' | sort)

if find "$TARGET_DIR" -type f -name '*-prd-v*.md' | grep -q . && \
   find "$TARGET_DIR" -type f -name 'api-endpoints.md' | grep -q . && \
   find "$TARGET_DIR" -type f -name 'api-models.md' | grep -q . && \
   find "$TARGET_DIR" -type f -name 'SUPABASE-PATTERNS.md' | grep -q .; then
  PRD_FILE="$(find "$TARGET_DIR" -type f -name '*-prd-v*.md' | sort | head -n 1)"
  ENDPOINTS_FILE="$(find "$TARGET_DIR" -type f -name 'api-endpoints.md' | sort | head -n 1)"
  MODELS_FILE="$(find "$TARGET_DIR" -type f -name 'api-models.md' | sort | head -n 1)"
  SUPABASE_FILE="$(find "$TARGET_DIR" -type f -name 'SUPABASE-PATTERNS.md' | sort | head -n 1)"

  check_cross_doc_consistency "$PRD_FILE" "$ENDPOINTS_FILE" "$MODELS_FILE" "$SUPABASE_FILE"
  check_rls_lint "$MODELS_FILE" "$SUPABASE_FILE"
  check_implementation_readiness "$PRD_FILE"
fi

exit "$FAILED"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS_DIR="$ROOT/tests/validator/pass"
FAIL_DIR="$ROOT/tests/validator/fail"
VALIDATOR="$ROOT/skills/prd-generator/scripts/validate-generated-docs.sh"
export PRD_GENERATOR_ALLOW_LEGACY_LABELS=0

run_expect_pass() {
  local fixture="$1"
  bash "$VALIDATOR" "$fixture"
}

run_expect_fail() {
  local fixture="$1"
  if bash "$VALIDATOR" "$fixture"; then
    echo "expected fixture to be rejected: $fixture"
    exit 1
  fi
}

run_expect_fail_with_message() {
  local fixture="$1"
  local expected="$2"
  local output

  if output="$(bash "$VALIDATOR" "$fixture" 2>&1)"; then
    echo "expected fixture to be rejected: $fixture"
    exit 1
  fi

  printf '%s\n' "$output" | grep -F "$expected" >/dev/null || {
    echo "expected failure output [$expected] for fixture $fixture"
    printf '%s\n' "$output"
    exit 1
  }
}

bash "$VALIDATOR" "$PASS_DIR"
if bash "$VALIDATOR" "$FAIL_DIR"; then
  echo "expected fail fixture to be rejected"
  exit 1
fi

run_expect_pass "$ROOT/tests/quality/pass-package"
run_expect_fail "$ROOT/tests/quality/fail-crossdoc"
run_expect_fail "$ROOT/tests/quality/fail-workflow-anchor"
run_expect_fail "$ROOT/tests/quality/fail-label-shapes"
run_expect_fail "$ROOT/tests/quality/fail-rls-lint"
run_expect_fail "$ROOT/tests/quality/fail-readiness"
run_expect_fail "$ROOT/tests/quality/fail-version-currency"
run_expect_pass "$ROOT/tests/quality/pass-access-control-consistency"
run_expect_fail_with_message "$ROOT/tests/quality/fail-access-control-consistency" "FAIL access-control-consistency"
run_expect_pass "$ROOT/tests/quality/pass-workflow-anchor-uniqueness"
run_expect_fail_with_message "$ROOT/tests/quality/fail-workflow-anchor-uniqueness" "FAIL workflow-anchor-uniqueness"
run_expect_pass "$ROOT/tests/quality/pass-language-pt-br"
run_expect_pass "$ROOT/tests/quality/pass-v2-future-versions"
run_expect_pass "$ROOT/tests/quality/pass-v2-launch-dependencies"
run_expect_pass "$ROOT/tests/quality/pass-v2-validation-plan"
run_expect_pass "$ROOT/tests/quality/pass-v2-scope-decisions"
run_expect_pass "$ROOT/tests/quality/pass-v2-rewrite"
run_expect_fail_with_message "$ROOT/tests/quality/fail-mutually-exclusive-sections" "mutually exclusive sections"
run_expect_fail_with_message "$ROOT/tests/quality/fail-scope-decisions-justification" "scope decision item missing reason"
run_expect_fail_with_message "$ROOT/tests/quality/fail-validation-plan-completeness" "validation plan missing field"

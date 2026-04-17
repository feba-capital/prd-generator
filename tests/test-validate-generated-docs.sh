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

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT/skills/prd-generator/scripts/validate-generated-docs.sh"
export PRD_GENERATOR_ALLOW_LEGACY_LABELS=0

echo "1. Multi-role visibility matrix test"
bash "$VALIDATOR" "$ROOT/tests/quality/pass-package"

echo "2. Derived-column test"
echo "TODO (P2): add an end-to-end generation fixture once the nextjs-supabase preset receives the pattern-to-mechanism defaults."

echo "3. Atomic write test"
echo "TODO (P2): add an end-to-end generation fixture once the skill promotes a transactional RPC default for multi-table writes."

echo "4. Scope drift test"
if bash "$VALIDATOR" "$ROOT/tests/quality/fail-workflow-anchor"; then
  echo "expected workflow anchor fixture to fail"
  exit 1
fi

echo "5. Opinionated default test"
echo "TODO (P2): add an end-to-end generation fixture once preset defaults for formatter, CI, error tracking, and admin bootstrap are implemented."

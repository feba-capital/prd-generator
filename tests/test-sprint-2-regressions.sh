#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT/skills/prd-generator/scripts/validate-generated-docs.sh"
COMMAND_FILE="$ROOT/commands/prd-generator.md"
SKILL_FILE="$ROOT/skills/prd-generator/SKILL.md"
LANGUAGE_FILE="$ROOT/skills/prd-generator/interview/language-question.md"
BRAINSTORM_FILE="$ROOT/skills/prd-generator/interview/brainstorm-readiness.md"
MVP_FILE="$ROOT/skills/prd-generator/interview/mvp-check.md"
SCOPE_CONTRACT_FILE="$ROOT/skills/prd-generator/interview/scope-contract.md"

echo "1. Language cascade test"
grep -F "Brazilian Portuguese" "$LANGUAGE_FILE" >/dev/null
grep -F "Português do Brasil" "$LANGUAGE_FILE" >/dev/null
bash "$VALIDATOR" "$ROOT/tests/quality/pass-language-pt-br"

echo "2. Fast-path test"
grep -F "Skip, I already scoped it" "$MVP_FILE" >/dev/null
grep -F "Already brainstormed" "$BRAINSTORM_FILE" >/dev/null
grep -F "under 30 seconds" "$SKILL_FILE" >/dev/null

echo "3. Scaffolding-path test"
grep -F "/brainstorm" "$BRAINSTORM_FILE" >/dev/null
grep -F "No brainstorm skill available" "$BRAINSTORM_FILE" >/dev/null
bash "$VALIDATOR" "$ROOT/tests/quality/pass-v2-future-versions"
grep -F "## Future Versions" "$ROOT/tests/quality/pass-v2-future-versions/docs/sample-prd-v1.0.md" >/dev/null

echo "4. Atomic product test"
bash "$VALIDATOR" "$ROOT/tests/quality/pass-v2-launch-dependencies"
grep -F "## Launch Dependencies" "$ROOT/tests/quality/pass-v2-launch-dependencies/docs/sample-prd-v1.0.md" >/dev/null
if grep -F "## Future Versions" "$ROOT/tests/quality/pass-v2-launch-dependencies/docs/sample-prd-v1.0.md" >/dev/null; then
  echo "atomic product fixture should not include Future Versions"
  exit 1
fi

echo "5. No-data test"
bash "$VALIDATOR" "$ROOT/tests/quality/pass-v2-validation-plan"
grep -F "Sample size" "$ROOT/tests/quality/pass-v2-validation-plan/docs/sample-prd-v1.0.md" >/dev/null
grep -F "Time window" "$ROOT/tests/quality/pass-v2-validation-plan/docs/sample-prd-v1.0.md" >/dev/null
grep -F "Success metric" "$ROOT/tests/quality/pass-v2-validation-plan/docs/sample-prd-v1.0.md" >/dev/null
grep -F "Kill threshold" "$ROOT/tests/quality/pass-v2-validation-plan/docs/sample-prd-v1.0.md" >/dev/null

echo "6. Override test"
bash "$VALIDATOR" "$ROOT/tests/quality/pass-v2-scope-decisions"
grep -F "Feature:" "$ROOT/tests/quality/pass-v2-scope-decisions/docs/sample-prd-v1.0.md" >/dev/null
grep -F "Reason:" "$ROOT/tests/quality/pass-v2-scope-decisions/docs/sample-prd-v1.0.md" >/dev/null

echo "7. Full rewrite test"
bash "$VALIDATOR" "$ROOT/tests/quality/pass-v2-rewrite"
grep -F "Recommendation rejected" "$ROOT/tests/quality/pass-v2-rewrite/docs/sample-prd-v1.0.md" >/dev/null

echo "8. Scope contract export test"
test -f "$ROOT/tests/self-test/gym-workouts/scope-contract.md"
grep -F "## Scope Contract (v1)" "$ROOT/tests/self-test/gym-workouts/scope-contract.md" >/dev/null
grep -F "### The Skateboard" "$ROOT/tests/self-test/gym-workouts/scope-contract.md" >/dev/null

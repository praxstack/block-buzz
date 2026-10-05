# Spec: pin `npx skills` in install-agent-skills.sh

Status: APPROVED (design review round 1)

## Problem

`scripts/install-agent-skills.sh` invokes `npx skills@latest`. That tag
moves without a review gate (CodeRabbit supply-chain finding).

## Decision

Pin `SKILLS=(skills@1.7.0)` (current `npm view skills version` as of
2026-10-05) and refuse to run if the array still contains `latest`.

## Tests

- Script contains `skills@1.7.0` and not `skills@latest`.
- `scripts/test-install-agent-skills-pin.sh` copies the production script,
  mutates the pin to `skills@latest`, and asserts the guard exits before a
  fake `npx` on `PATH` is reached. Removing the `latest` check fails this
  test.

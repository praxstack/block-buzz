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
- Guard rejects a `latest` value (static review of the `if` check).

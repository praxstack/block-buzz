# Plan 005: Community reset inventory guard test

> **Drift check**: `git diff --stat 172c3d85..HEAD -- desktop/src/features/communities/`

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/002-community-switch-reset-completeness.md
- **Category**: tests
- **Planned at**: commit `172c3d85`, 2026-08-29

## Why this matters

AGENTS.md requires every community-scoped singleton to register in
`resetCommunityState()`, but nothing enforces it. New caches leak across
community switches when developers forget the manual inventory.

## Current state

- `desktop/src/features/communities/useCommunityInit.ts:54-84` — manual reset list
- `AGENTS.md` Community Switching section documents the contract
- No test references `resetCommunityState` callees vs `export function reset*` modules

Intentional non-resets documented: `selfProfileStorage.ts` (per-community keying).

## Commands

| Purpose | Command | Expected |
|---------|---------|----------|
| New test | `cd desktop && pnpm exec vitest run src/features/communities/useCommunityInit.reset-inventory.test.mjs` | pass |
| Desktop check | `cd desktop && pnpm run check` | exit 0 |

## Scope

**In scope**: new test file under `desktop/src/features/communities/`, optional allowlist file

**Out of scope**: Implementing CommunityScope container

## Steps

### Step 1: Parse resetCommunityState callees

Read `useCommunityInit.ts` and extract function names called inside
`resetCommunityState` (e.g. `resetMediaCaches`, `clearMarkdownNodeCache`).

### Step 2: Discover community-scoped reset exports

Grep `desktop/src` for `export function reset` and module-level Maps with
`reset*` functions. Filter to community-scoped paths (exclude test-only, exclude
documented intentional non-resets).

### Step 3: Fail on drift

Test asserts: every discovered `reset*` (minus allowlist) appears in the callee set.

Allowlist file: `desktop/src/features/communities/reset-inventory-allowlist.json`
with entries like `selfProfileStorage` and rationale comments.

**Verify**: test fails if you add a fake `resetFooStore` without wiring it

### Step 4: Optional — aspect ratio caches

If `learnedVideoAspectRatios` / `decodedImageDimensions` get reset functions in
plan 002 follow-up, include them in inventory.

## Done criteria

- [ ] `useCommunityInit.reset-inventory.test.mjs` exists and passes
- [ ] Allowlist documents intentional exclusions
- [ ] CI desktop unit job runs the test
- [ ] plans/README.md row 005 → DONE

## STOP conditions

- More than 5 false positives from non-community resets — refine grep heuristics before allowlisting broadly.

## Maintenance notes

- Reviewers: new `reset*` export in `desktop/src` should trigger test update or allowlist entry with comment.

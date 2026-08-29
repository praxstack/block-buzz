# Plan 002: Complete community-switch singleton resets

> **Executor instructions**: Follow step by step. Run verification after each step.
> **Drift check**: `git diff --stat 172c3d85..HEAD -- desktop/src/features/communities/useCommunityInit.ts`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `172c3d85`, 2026-08-29

## Why this matters

`resetCommunityState()` in `useCommunityInit.ts` is the canonical inventory of
community-scoped module-level state. Several stores are missing: moderation
timeout blocks the composer in the wrong community; card mint jobs/toasts leak;
pending agent navigation payloads can fire after a switch.

## Current state

- `desktop/src/features/communities/useCommunityInit.ts:54-84` — `resetCommunityState` calls ~20 resets but omits:
  - `clearTimeoutState` from `desktop/src/features/moderation/lib/timeoutStore.ts:64`
  - `resetCardMintStore` from `desktop/src/features/agents/cardMintStore.ts:190`
  - Pending payloads in `openCreateAgentEvent.ts`, `openEditAgentEvent.ts`, `openSnapshotImportFromUrlEvent.ts:20`
- `timeoutStore.ts:9-12` documents single-community assumption that breaks on switch
- Pattern exemplar: `clearMarkdownNodeCache()` already wired at line 82

## Commands you will need

| Purpose | Command | Expected |
|---------|---------|----------|
| Desktop unit tests | `cd desktop && pnpm exec vitest run src/features/communities src/features/moderation src/features/agents/cardMintStore.test.mjs` | all pass |
| Typecheck | `cd desktop && pnpm exec tsc --noEmit` | exit 0 |
| Lint | `cd desktop && pnpm exec biome check src/features/communities/useCommunityInit.ts` | exit 0 |

## Scope

**In scope**:
- `desktop/src/features/communities/useCommunityInit.ts`
- `desktop/src/features/agents/openSnapshotImportFromUrlEvent.ts` (add `clearPendingSnapshotImport` if missing)
- `desktop/src/features/agents/openCreateAgentEvent.ts` / `openEditAgentEvent.ts` (add clear exports if missing)
- New/extended tests in existing `*.test.mjs` files

**Out of scope**:
- CommunityScope container refactor (architecture candidate — separate effort)
- `learnedVideoAspectRatios` / `decodedImageDimensions` (plan 005 inventory)

## Steps

### Step 1: Wire timeout reset

Import `clearTimeoutState` from `@/features/moderation/lib/timeoutStore` and
call it inside `resetCommunityState()` after `relayClient.disconnect()`.

**Verify**: `grep clearTimeoutState desktop/src/features/communities/useCommunityInit.ts` → match

### Step 2: Wire card mint reset

Import `resetCardMintStore` from `@/features/agents/cardMintStore` and call in
`resetCommunityState()`.

**Verify**: grep shows call in `useCommunityInit.ts`

### Step 3: Clear pending agent navigation payloads

For each of `openCreateAgentEvent`, `openEditAgentEvent`,
`openSnapshotImportFromUrlEvent`:
- Export `clearPending*()` that sets module-level pending to `null`
- Call all three from `resetCommunityState()`

**Verify**: unit tests in `openSnapshotImportFromUrlEvent.test.mjs` (or new test)
assert pending cleared and not consumed after switch

### Step 4: Add timeout switch test

Extend `cardMintStore.test.mjs` or add `useCommunityInit.reset.test.mjs`:
- Record timeout active → call `resetCommunityState` equivalent exports → assert
  `getTimeoutState().active === false`

**Verify**: vitest run passes

## Done criteria

- [ ] `clearTimeoutState`, `resetCardMintStore`, and all pending clears called in `resetCommunityState`
- [ ] At least one new test covers timeout or pending clear on reset
- [ ] `pnpm exec tsc --noEmit` in desktop exits 0
- [ ] `plans/README.md` row 002 → DONE

## STOP conditions

- `resetCommunityState` signature or async behavior differs from excerpt — read live file first.
- Clearing pending navigation breaks intentional cross-community deep links — report before removing behavior.

## Maintenance notes

- AGENTS.md "Community Switching" inventory: any new module-level cache needs
  `reset*` wired here; plan 005 adds automated guard.

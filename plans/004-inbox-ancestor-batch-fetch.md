# Plan 004: Batch inbox thread ancestor fetches

> **Drift check**: `git diff --stat 172c3d85..HEAD -- desktop/src/features/home/useInboxThreadContext.ts`

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: perf
- **Planned at**: commit `172c3d85`, 2026-08-29

## Why this matters

Opening a deep thread in the home inbox walks ancestors with one `getEventById`
call per hop (up to 50), causing serial network latency before descendants load.

## Current state

`desktop/src/features/home/useInboxThreadContext.ts:109-143`:

```typescript
const fetchEvent = async (eventId: string) => {
  ...
  const event = await getEventById(eventId);
```

Batch API exists: `get_events` with chunking in
`desktop/src-tauri/src/commands/messages/event_batch.rs` (`EVENT_QUERY_CHUNK_SIZE = 1_000`).

## Commands

| Purpose | Command | Expected |
|---------|---------|----------|
| Desktop unit tests | `cd desktop && pnpm exec vitest run src/features/home` | pass |
| Typecheck | `cd desktop && pnpm exec tsc --noEmit` | exit 0 |

## Scope

**In scope**: `useInboxThreadContext.ts`, possibly shared batch helper if one exists

**Out of scope**: Relay protocol changes, mobile inbox

## Steps

### Step 1: Collect ancestor IDs without fetching

Walk tags from `selectedParentId` up to `threadRootId`, building `Set<string>` of
IDs to resolve (reuse existing `seen` / `MAX_ANCESTOR_HOPS` logic).

### Step 2: Batch resolve via get_events

Replace per-hop `getEventById` with a single batched call (or chunked calls)
using the same API other thread views use. Populate `eventsById` from batch result.

### Step 3: Preserve failure semantics

If any ID missing from batch, set `failed = true` as today.

**Verify**: add unit test with mocked `getEventById`/`get_events` showing one batch call for N ancestors

## Done criteria

- [ ] Ancestor resolution uses ≤ ceil(N/1000) batch calls, not N serial calls
- [ ] Existing inbox thread tests pass
- [ ] plans/README.md row 004 → DONE

## STOP conditions

- No batch `get_events` export available from `@/shared/api` — find correct import path from `event_batch` consumers before improvising.

## Maintenance notes

- If pagination changes for thread roots, keep batch chunk size aligned with `EVENT_QUERY_CHUNK_SIZE`.

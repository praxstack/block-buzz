# Spec: #7950 mention filter drops agents with a null displayName

Status: APPROVED (design review round 1)

## Problem

Typing a prefix in `@` mention autocomplete hides agents the unfiltered list
still shows. `rankMentionCandidates` scores `displayName` / `personaName` /
`secondaryLabel` only when they are truthy, and the picker label is computed
separately (`displayName ?? truncateNpub`). An empty or whitespace
`displayName` is shown as a truncated npub (or a persona name elsewhere) while
a non-hex query such as `v` cannot match pubkey and never scores the resolved
label. Kind:0 / kind:10100 "Vera" with a null `displayName` therefore vanishes
once the user types.

## Decision

Resolve one display label for ranking and for the picker:
`displayName.trim()` else `personaName.trim()` else truncated npub. Score that
resolved label (plus the existing trimmed fields). Empty-query pubkey matches
stay; a prefix query must match what the row displays.

## Non-goals

Changing mention eligibility, coalescing, or kind:0 profile fetch. Auth,
privacy, and membership gates stay as they are.

## Tests

- Prefix `v` matches an agent whose `displayName` is null and `personaName` is
  `Vera`.
- Whitespace-only `displayName` does not block `personaName` prefix matching.
- Removing the resolved-label score fails the Vera prefix case.

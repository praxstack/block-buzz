# Spec: #8093 remote agents missing from @mention autocomplete

Status: APPROVED (design review round 2)

## Problem

`relayAgentIsSharedWithUser` admits the owner only when `respondTo` is
`owner-only`, `allowlist`, or `anyone`. Remote ACP agents often publish
`respondTo: null` (unset on the kind:0 / directory card). Members list still
shows them; autocomplete hides them because null fails the owner gate and
the anyone+shared-channel gate.

## Decision

Treat `null` like an unset anyone policy for shared channels, and admit
the attested owner for every policy except explicit `nobody`. Do not add
`nobody` to `RespondToMode`.

## Tests

- owner + null is shared
- null + shared channel is shared for non-owners
- owner + nobody stays excluded

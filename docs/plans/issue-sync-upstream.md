# Spec: sync praxstack fork with upstream/main

Status: APPROVED (design review round 1)

## Problem

`origin/main` on praxstack/block-buzz is about 247 commits behind
`block/buzz` `upstream/main`. Product follow-ups cannot land against
current upstream without folding that sync into every issue PR.

## Decision

Merge `origin/main` then `upstream/main` into `prax/sync-upstream-a3ec`.
Do not force-push `main`. Product issue PRs use this branch as base until
the sync merges.

AGENTS.md conflict: keep upstream mention-editor guidance and the fork
graphify navigation rules.

## Tests

- Merge commit ancestors include both `origin/main` and `upstream/main`.
- `git merge-base --is-ancestor` holds for both tips on the head SHA.
- No force-push of `main`.

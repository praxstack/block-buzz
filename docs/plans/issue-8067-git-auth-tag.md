# Spec: #8067 merge review 403 on agent-owned git repos

Status: APPROVED (design review round 2)

## Problem

`merge_project_pull_request` authenticates git as the managed owner via
`git-credential-nostr`. The helper signs NIP-98 and, for NIP-OA agents,
must attach `BUZZ_AUTH_TAG`. `GitAuthConfig` only carries the nsec, so
clones/fetches as the agent get 403 from the relay.

`project_owner_identity` already returns `auth_tag`.

## Decision

Add optional `auth_tag` to `GitAuthConfig`. Set `BUZZ_AUTH_TAG` on git
subprocesses that need credentials; remove it otherwise so a parent env
cannot leak. Merge uses `with_auth_tag(owner_identity.auth_tag)`.

## Tests

- `credential_process_env` includes `BUZZ_AUTH_TAG` only when the tag is
  non-empty

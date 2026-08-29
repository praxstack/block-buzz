# Plan 003: Deduplicate cloud-agent bootstrap with Justfile recipes

> **Drift check**: `git diff --stat 172c3d85..HEAD -- scripts/cloud-agent-start.sh scripts/cloud-agent-install.sh Justfile`

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: MED
- **Depends on**: plans/001-cloud-agent-security-hardening.md
- **Category**: tech-debt
- **Planned at**: commit `172c3d85`, 2026-08-29

## Why this matters

`cloud-agent-start.sh` duplicates health waits, migrations, and seeding that
`Justfile` `_ensure-services` / `_ensure-migrations` already implement.
`cloud-agent-install.sh` calls start during install, and `.cursor/environment.json`
runs start again — double bootstrap every session.

## Current state

- `scripts/cloud-agent-start.sh:87-116` — inline compose up, health wait, migrate, seed
- `Justfile:182-210` — `_ensure-services`, `_ensure-migrations`
- `scripts/cloud-agent-install.sh:9` — invokes `cloud-agent-start.sh` before `.env` copy
- `.cursor/environment.json:8-9` — separate install and start hooks

## Commands

| Purpose | Command | Expected |
|---------|---------|----------|
| Idempotent start | run `scripts/cloud-agent-start.sh` twice | second run fast/no error |
| Setup smoke | `just _ensure-migrations` (with services up) | exit 0 |

## Scope

**In scope**: `scripts/cloud-agent-start.sh`, `scripts/cloud-agent-install.sh`, optional `Justfile` (`_ensure-services-cloud` recipe)

**Out of scope**: Dockerfile sudo (plan 001), relay service set changes

## Steps

### Step 1: Split Docker prelude from service bootstrap

Keep in `cloud-agent-start.sh` only: Hermit activation, `ensure_docker()`, optional
Keycloak/Prometheus stop. Replace lines 87-116 with:

```bash
"${REPO_ROOT}/bin/just" _ensure-migrations
```

Or add `just _ensure-services-cloud` that starts only postgres/redis/minio/adminer
then calls `_ensure-migrations`.

**Verify**: `grep -c 'cargo run -p buzz-admin' scripts/cloud-agent-start.sh` → 0

### Step 2: Fix install/start double execution

Option A: Remove `cloud-agent-start.sh` from `cloud-agent-install.sh`; install
only builds deps (`just bootstrap`, Playwright, hooks).

Option B: Make start idempotent with early exit when `docker inspect buzz-postgres`
is healthy.

Document chosen approach in AGENTS.md.

**Verify**: environment install+start logs show single migration pass

### Step 3: Copy `.env` before infra bootstrap in install

In `cloud-agent-install.sh`, move `.env` copy and `ensure-local-relay-key.sh`
before any start/just call.

**Verify**: read install script order — `.env` exists before `just _ensure-migrations`

## Done criteria

- [ ] Shared tail delegated to Justfile
- [ ] No double migration on typical Cloud Agent boot
- [ ] `shellcheck` passes on both scripts
- [ ] plans/README.md row 003 → DONE

## STOP conditions

- `bin/just` unavailable during Cloud Agent install — ensure Hermit activation precedes just calls.
- `_ensure-services` starts Keycloak — must use subset recipe (OOM fix from PR #4).

## Maintenance notes

- Future Justfile service changes automatically apply to Cloud Agents once deduped.

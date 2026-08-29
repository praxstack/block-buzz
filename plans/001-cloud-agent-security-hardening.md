# Plan 001: Harden Cloud Agent sudo and Docker socket permissions

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise.
>
> **Drift check (run first)**: `git diff --stat 172c3d85..HEAD -- .cursor/Dockerfile scripts/cloud-agent-start.sh`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: security
- **Planned at**: commit `172c3d85`, 2026-08-29

## Why this matters

PR #6 widened Cloud Agent sudo from a scoped allowlist to `NOPASSWD: ALL`, and
`cloud-agent-start.sh` world-writes the Docker socket (`chmod 666`). Any process
running as `ubuntu` in the agent VM can escalate to root-equivalent access via
either path. This plan restores least-privilege sudo while keeping bootstrap
working, and relies on the `docker` group for socket access.

## Current state

- `.cursor/Dockerfile:38-39` — blanket sudoers rule:
  ```dockerfile
  && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ubuntu-cloud-agent \
  ```
- `.cursor/Dockerfile:41` — `usermod -aG docker ubuntu`
- `scripts/cloud-agent-start.sh:39` — `sudo mkdir -p /etc/docker` (needs sudoers entry)
- `scripts/cloud-agent-start.sh:41` — `sudo tee /etc/docker/daemon.json`
- `scripts/cloud-agent-start.sh:46` — `sudo "${dockerd_bin}" ...`
- `scripts/cloud-agent-start.sh:61` — `sudo chmod 666 /var/run/docker.sock`
- `scripts/cloud-agent-start.sh:76-84` — `ensure_minio_bucket` swallows errors with `|| true`

Commit message style (from recent history): `fix: <description>` with `-s` signoff.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Shellcheck | `shellcheck scripts/cloud-agent-start.sh` | exit 0 |
| Local smoke (if Docker available) | `scripts/cloud-agent-start.sh` | exits 0, `docker info` works as ubuntu |
| CI gate | `just check` | exit 0 (path-scoped if only these files change) |

## Scope

**In scope**:
- `.cursor/Dockerfile`
- `scripts/cloud-agent-start.sh`
- `AGENTS.md` (Cloud Agents section — update sudo/socket docs only)

**Out of scope**:
- `scripts/cloud-agent-install.sh` ordering (plan 003)
- Relay auth env vars
- Any non-cloud-agent Dockerfile

## Git workflow

- Branch: `prax/cloud-agent-sudo-scope-74e3`
- Commit: `git commit -s -m "fix: scope Cloud Agent sudo and drop world-writable docker.sock"`
- Push and open PR per repo conventions

## Steps

### Step 1: Replace NOPASSWD ALL with scoped allowlist

In `.cursor/Dockerfile`, replace the sudoers line with an explicit allowlist
covering every privileged command in `cloud-agent-start.sh`:

```dockerfile
&& printf '%s\n' \
  'ubuntu ALL=(ALL) NOPASSWD: /usr/bin/dockerd' \
  'ubuntu ALL=(ALL) NOPASSWD: /usr/sbin/dockerd' \
  'ubuntu ALL=(ALL) NOPASSWD: /usr/bin/mkdir' \
  'ubuntu ALL=(ALL) NOPASSWD: /usr/bin/tee' \
  'ubuntu ALL=(ALL) NOPASSWD: /usr/bin/chmod' \
  'ubuntu ALL=(ALL) NOPASSWD: /bin/chmod' \
  > /etc/sudoers.d/ubuntu-cloud-agent \
```

**Verify**: `grep -c 'NOPASSWD: ALL' .cursor/Dockerfile` → `0`

### Step 2: Remove world-writable Docker socket chmod

Delete line 61 (`sudo chmod 666 /var/run/docker.sock`) from
`scripts/cloud-agent-start.sh`. After `dockerd` starts, verify access with
`docker info` (already done at line 55). If `docker info` fails for group
reasons, add `sudo chown root:docker /var/run/docker.sock && sudo chmod 660`
and add `/usr/bin/chown` to the sudoers allowlist.

**Verify**: `grep -n 'chmod 666' scripts/cloud-agent-start.sh` → no matches

### Step 3: Propagate MinIO bucket failures

In `ensure_minio_bucket`, remove `>/dev/null 2>&1 || true`. Capture stderr;
on failure print last lines and `exit 1`.

**Verify**: `grep '|| true' scripts/cloud-agent-start.sh` — only acceptable on
non-critical paths (document any remaining `|| true` in commit message)

### Step 4: Update AGENTS.md Cloud Agents section

Document scoped sudo and docker-group socket access (2–3 sentences). Remove
stale claim that start calls `just _ensure-services` if still present.

**Verify**: `grep -A5 'Cloud Agents' AGENTS.md` mentions scoped sudo

## Test plan

- Manual: rebuild Cloud Agent image or run start script as `ubuntu` user;
  confirm `docker compose ps` works without `chmod 666`.
- No new unit tests required; optional: add `scripts/test-cloud-agent-sudoers.sh`
  that greps Dockerfile for forbidden `NOPASSWD: ALL`.

## Done criteria

- [ ] No `NOPASSWD: ALL` in `.cursor/Dockerfile`
- [ ] No `chmod 666` on docker.sock in start script
- [ ] `ensure_minio_bucket` fails loudly on error
- [ ] `shellcheck scripts/cloud-agent-start.sh` exits 0
- [ ] `plans/README.md` status row for 001 updated to DONE

## STOP conditions

- `docker info` fails as `ubuntu` after removing chmod 666 and scoped sudo is
  insufficient — report which command needs elevation.
- Cloud Agent environment build fails on `sudo mkdir` — add missing binary to
  allowlist rather than reverting to ALL.

## Maintenance notes

- Any new `sudo` invocation in cloud-agent scripts must be added to the
  Dockerfile allowlist in the same PR.
- Reviewers: reject PRs that widen sudo beyond explicit command paths.

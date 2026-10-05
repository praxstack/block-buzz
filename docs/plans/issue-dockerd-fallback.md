# Spec: Cloud Agent dockerd apt fallback

Status: APPROVED (design review round 1)

## Problem

JIT Cloud Agent VMs can boot without `dockerd` even though
`.cursor/Dockerfile` installs `docker.io`. `cloud-agent-start.sh`
exited immediately, so Postgres/Redis never came up
(`/tmp/cursor/start-user/start-user.status` = 1).

`prax/fix-dockerd-path-74e3` only searched extra PATH locations.

## Decision

If `dockerd` is missing and `apt-get` exists, install
`docker.io`, `docker-compose-v2`, and `fuse-overlayfs` via
noninteractive apt (sudo when not root), then start the daemon as
today.

## Tests

- `bash -n scripts/cloud-agent-start.sh`
- Script contains `install_docker_packages_if_missing` and no longer
  treats a missing binary as a hard "install it in the image" exit
  before attempting apt.
- Skip-install requires dockerd, the compose plugin, and fuse-overlayfs.
- `write_docker_daemon_json` runs before `apt-get install`.
- Socket access is granted before `docker info` polling.

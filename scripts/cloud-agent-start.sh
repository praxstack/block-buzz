#!/usr/bin/env bash
# Per-boot startup: Docker daemon, compose services, MinIO bucket, migrations.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC1091
. ./bin/activate-hermit
export PATH="${REPO_ROOT}/bin:${PATH}"

DOCKER_DAEMON_JSON='{"storage-driver":"fuse-overlayfs","iptables":false,"bridge":"none"}'

resolve_dockerd_bin() {
  if command -v dockerd >/dev/null 2>&1; then
    command -v dockerd
    return 0
  fi
  for candidate in /usr/bin/dockerd /usr/sbin/dockerd; do
    if [[ -x "${candidate}" ]]; then
      echo "${candidate}"
      return 0
    fi
  done
  return 1
}

# JIT Cloud Agent images sometimes omit docker.io even when Dockerfile
# lists it. Install from apt once so start can recover instead of exiting.
root_env() {
  if [[ "$(id -u)" -eq 0 ]]; then
    env "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo env "$@"
  else
    echo "[cloud-agent-start] need root or sudo to run: $*" >&2
    exit 1
  fi
}

docker_compose_plugin_present() {
  local plugin
  for plugin in \
    /usr/libexec/docker/cli-plugins/docker-compose \
    /usr/lib/docker/cli-plugins/docker-compose \
    /usr/local/lib/docker/cli-plugins/docker-compose
  do
    if [[ -x "${plugin}" ]]; then
      return 0
    fi
  done
  command -v docker-compose >/dev/null 2>&1
}

fuse_overlayfs_present() {
  command -v fuse-overlayfs >/dev/null 2>&1
}

docker_runtime_packages_present() {
  resolve_dockerd_bin >/dev/null && docker_compose_plugin_present && fuse_overlayfs_present
}

# Write daemon.json before apt so a package postinst that starts docker.service
# already has fuse-overlayfs / iptables / bridge settings.
write_docker_daemon_json() {
  root_env mkdir -p /etc/docker
  if [[ ! -f /etc/docker/daemon.json ]] || ! grep -q fuse-overlayfs /etc/docker/daemon.json 2>/dev/null; then
    printf '%s\n' "${DOCKER_DAEMON_JSON}" | root_env tee /etc/docker/daemon.json >/dev/null
  fi
}

grant_docker_socket_access() {
  if [[ -S /var/run/docker.sock ]]; then
    root_env chmod 666 /var/run/docker.sock 2>/dev/null || true
  fi
}

stop_package_dockerd() {
  if command -v systemctl >/dev/null 2>&1; then
    root_env systemctl stop docker 2>/dev/null || true
  fi
  root_env pkill -x dockerd 2>/dev/null || true
  local _
  for _ in $(seq 1 10); do
    if ! pgrep -x dockerd >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
}

wait_for_docker_info() {
  local _
  for _ in $(seq 1 60); do
    grant_docker_socket_access
    if docker info >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

install_docker_packages_if_missing() {
  if docker_runtime_packages_present; then
    return 0
  fi
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "[cloud-agent-start] docker runtime packages missing and apt-get is unavailable; install docker.io docker-compose-v2 fuse-overlayfs in the image" >&2
    exit 1
  fi
  echo "[cloud-agent-start] docker runtime incomplete; installing docker.io docker-compose-v2 fuse-overlayfs via apt-get..."
  root_env DEBIAN_FRONTEND=noninteractive apt-get update -qq
  root_env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker.io docker-compose-v2 fuse-overlayfs
  hash -r || true
  if ! docker_runtime_packages_present; then
    echo "[cloud-agent-start] apt install finished but dockerd, compose plugin, or fuse-overlayfs is still missing" >&2
    exit 1
  fi
}

ensure_docker() {
  grant_docker_socket_access
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  write_docker_daemon_json
  install_docker_packages_if_missing
  grant_docker_socket_access
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  local dockerd_bin
  dockerd_bin="$(resolve_dockerd_bin)" || {
    echo "[cloud-agent-start] dockerd not found after install attempt" >&2
    exit 1
  }

  # Package postinst or a leftover daemon may be running but unusable (wrong
  # config or socket perms). Restart so daemon.json and the unix socket apply.
  if pgrep -x dockerd >/dev/null 2>&1; then
    echo "[cloud-agent-start] Restarting unusable dockerd..."
    stop_package_dockerd
  fi

  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "[cloud-agent-start] Starting Docker daemon (${dockerd_bin})..."
    sudo "${dockerd_bin}" --host=unix:///var/run/docker.sock >/tmp/dockerd.log 2>&1 &
  fi

  if ! wait_for_docker_info; then
    echo "[cloud-agent-start] Docker daemon failed to start; see /tmp/dockerd.log" >&2
    tail -20 /tmp/dockerd.log >&2 || true
    exit 1
  fi
}

wait_for_service_health() {
  local container="$1"
  local attempts="${2:-40}"
  for _ in $(seq 1 "${attempts}"); do
    if docker inspect --format '{{.State.Health.Status}}' "${container}" 2>/dev/null | grep -qx healthy; then
      return 0
    fi
    sleep 3
  done
  return 1
}

ensure_minio_bucket() {
  if ! curl -sf http://127.0.0.1:9000/minio/health/live >/dev/null 2>&1; then
    return 0
  fi

  echo "[cloud-agent-start] Ensuring MinIO buzz-media bucket exists..."
  docker run --rm --network host --entrypoint /bin/sh minio/mc:latest \
    -c 'mc alias set local http://127.0.0.1:9000 buzz_dev buzz_dev_secret && mc mb --ignore-existing local/buzz-media' \
    >/dev/null 2>&1 || true
}

echo "[cloud-agent-start] Ensuring Docker..."
ensure_docker

echo "[cloud-agent-start] Starting core dev services (postgres, redis, minio, adminer)..."
docker compose up -d postgres redis minio adminer

echo -n "[cloud-agent-start] Waiting for Postgres and Redis"
ready=0
for _ in $(seq 1 40); do
  pg=$(docker inspect --format '{{.State.Health.Status}}' buzz-postgres 2>/dev/null || echo not_found)
  redis=$(docker inspect --format '{{.State.Health.Status}}' buzz-redis 2>/dev/null || echo not_found)
  if [[ "${pg}" == "healthy" && "${redis}" == "healthy" ]]; then
    echo " ready"
    ready=1
    break
  fi
  echo -n "."
  sleep 3
done
if [[ "${ready}" -ne 1 ]]; then
  echo " timed out" >&2
  exit 1
fi

wait_for_service_health buzz-minio 20 || true
ensure_minio_bucket

echo "[cloud-agent-start] Running database migrations..."
cargo run -p buzz-admin -- migrate
./scripts/seed-local-community.sh

# Keycloak/Prometheus use host-gateway and heavy JVM/memory; skip them in Cloud Agents.
docker compose stop keycloak prometheus 2>/dev/null || true

echo "[cloud-agent-start] Dev infrastructure ready."

#!/usr/bin/env bash
# Per-boot startup: Docker daemon, compose services, MinIO bucket, migrations.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC1091
. ./bin/activate-hermit
export PATH="${REPO_ROOT}/bin:${PATH}"

DOCKER_DAEMON_JSON='{"storage-driver":"fuse-overlayfs","iptables":false,"bridge":"none"}'

ensure_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  sudo mkdir -p /etc/docker
  if [[ ! -f /etc/docker/daemon.json ]] || ! grep -q fuse-overlayfs /etc/docker/daemon.json 2>/dev/null; then
    printf '%s\n' "${DOCKER_DAEMON_JSON}" | sudo tee /etc/docker/daemon.json >/dev/null
  fi

  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "[cloud-agent-start] Starting Docker daemon..."
    sudo dockerd --host=unix:///var/run/docker.sock >/tmp/dockerd.log 2>&1 &
    for _ in $(seq 1 60); do
      if docker info >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "[cloud-agent-start] Docker daemon failed to start; see /tmp/dockerd.log" >&2
    tail -20 /tmp/dockerd.log >&2 || true
    exit 1
  fi

  sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
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

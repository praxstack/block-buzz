#!/usr/bin/env bash
# Per-boot startup: Docker daemon, compose services, MinIO bucket, migrations.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC1091
. ./bin/activate-hermit
export PATH="${REPO_ROOT}/bin:${PATH}"

ensure_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  sudo mkdir -p /etc/docker
  if [[ ! -f /etc/docker/daemon.json ]]; then
    printf '%s\n' '{"storage-driver":"vfs"}' | sudo tee /etc/docker/daemon.json >/dev/null
  fi

  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "[cloud-agent-start] Starting Docker daemon..."
    sudo dockerd --iptables=false >/tmp/dockerd.log 2>&1 &
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

ensure_minio_bucket() {
  if ! curl -sf http://127.0.0.1:9000/minio/health/live >/dev/null 2>&1; then
    return 0
  fi

  echo "[cloud-agent-start] Ensuring MinIO buzz-media bucket exists..."
  docker run --rm --network host --entrypoint /bin/sh minio/mc:latest \
    -c 'mc alias set local http://127.0.0.1:9000 buzz_dev buzz_dev_secret && mc mb --ignore-existing local/buzz-media' \
    >/dev/null
}

echo "[cloud-agent-start] Ensuring Docker..."
ensure_docker

echo "[cloud-agent-start] Starting Postgres, Redis, MinIO, and supporting services..."
just _ensure-services

ensure_minio_bucket

echo "[cloud-agent-start] Running database migrations..."
just _ensure-migrations

echo "[cloud-agent-start] Dev infrastructure ready."

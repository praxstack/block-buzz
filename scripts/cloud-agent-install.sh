#!/usr/bin/env bash
# Idempotent Cloud Agent install: infra bootstrap, Hermit toolchain, JS deps, core Rust builds.
# Install runs before start during environment builds, so bootstrap Docker/services here.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

"${REPO_ROOT}/scripts/cloud-agent-start.sh"

# shellcheck disable=SC1091
. ./bin/activate-hermit
export PATH="${REPO_ROOT}/bin:${PATH}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi
./scripts/ensure-local-relay-key.sh .env

echo "[cloud-agent-install] Ensuring Hermit toolchain..."
cargo --version >/dev/null
node --version >/dev/null
pnpm --version >/dev/null

echo "[cloud-agent-install] Installing desktop and web dependencies..."
(cd desktop && pnpm install --frozen-lockfile)
(cd web && pnpm install --frozen-lockfile)

echo "[cloud-agent-install] Pre-building relay, admin CLI, and buzz CLI..."
cargo build -p buzz-relay -p buzz-admin -p buzz-cli

echo "[cloud-agent-install] Installing Playwright Chromium for desktop screenshots..."
(cd desktop && pnpm exec playwright install chromium)

echo "[cloud-agent-install] Installing git hooks..."
just hooks

echo "[cloud-agent-install] Installing gstack Cursor skills (project-level)..."
"${REPO_ROOT}/scripts/install-gstack-skills.sh"

echo "[cloud-agent-install] Installing repo-level agent tools (OpenSpec, agent-browser, Graphify)..."
"${REPO_ROOT}/scripts/setup-agent-stack.sh"

echo "[cloud-agent-install] Done."

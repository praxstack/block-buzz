#!/usr/bin/env bash
# Install repo-level agent tooling: OpenSpec, Graphify, agent-browser CLI, Context7 MCP template.
# Idempotent — safe to re-run from cloud-agent-install or manually after clone.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

"${REPO_ROOT}/scripts/install-repo-intelligence.sh"

# shellcheck disable=SC1091
if [[ -f "${REPO_ROOT}/bin/activate-hermit" ]]; then
  . "${REPO_ROOT}/bin/activate-hermit"
fi
export PATH="${REPO_ROOT}/bin:${PATH}"

echo "[setup-agent-stack] agent-browser CLI (live Playwright automation)..."
if command -v agent-browser >/dev/null 2>&1; then
  echo "[setup-agent-stack] agent-browser: $(agent-browser --version 2>/dev/null || echo present)"
else
  npm install -g agent-browser
fi
if ! agent-browser --version >/dev/null 2>&1; then
  echo "[setup-agent-stack] Warning: agent-browser not on PATH after install" >&2
else
  # Download Chrome if missing; --with-deps on Linux when launch fails.
  agent-browser install 2>/dev/null || agent-browser install --with-deps 2>/dev/null || true
fi

echo "[setup-agent-stack] Done."

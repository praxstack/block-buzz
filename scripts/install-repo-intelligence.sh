#!/usr/bin/env bash
# Install repo intelligence tooling: OpenSpec, Graphify. Serena is optional (see README).
# Idempotent — safe to re-run from cloud-agent-install or after clone.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC1091
if [[ -f "${REPO_ROOT}/bin/activate-hermit" ]]; then
  . "${REPO_ROOT}/bin/activate-hermit"
fi
export PATH="${REPO_ROOT}/bin:${PATH}"

node_major() {
  node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0
}

echo "[install-repo-intelligence] OpenSpec (spec-driven change proposals)..."
NODE_MAJOR="$(node_major)"
if [[ "${NODE_MAJOR}" -ge 20 ]]; then
  if command -v openspec >/dev/null 2>&1; then
    echo "[install-repo-intelligence] openspec already installed: $(openspec --version 2>/dev/null || openspec version 2>/dev/null || echo present)"
  else
    npm install -g @fission-ai/openspec@latest
  fi
  if [[ ! -d "${REPO_ROOT}/openspec" ]]; then
    echo "[install-repo-intelligence] Initializing OpenSpec in repo (non-interactive)..."
    openspec init "${REPO_ROOT}" 2>/dev/null \
      || openspec init 2>/dev/null \
      || true
  else
    echo "[install-repo-intelligence] openspec/ already present — skip init"
  fi
else
  echo "[install-repo-intelligence] Skipping OpenSpec (Node.js >= 20 required; found major=${NODE_MAJOR})" >&2
fi

echo "[install-repo-intelligence] Graphify (code graph for Cursor)..."
if command -v uv >/dev/null 2>&1; then
  if ! command -v graphify >/dev/null 2>&1; then
    uv tool install graphifyy 2>/dev/null \
      || echo "[install-repo-intelligence] graphifyy install failed — skip or install manually" >&2
  fi
  if command -v graphify >/dev/null 2>&1; then
    graphify install --project --platform cursor 2>/dev/null \
      || graphify install --project 2>/dev/null \
      || echo "[install-repo-intelligence] graphify install --project skipped (non-fatal)" >&2
  fi
else
  echo "[install-repo-intelligence] Skipping Graphify (uv not found — https://docs.astral.sh/uv/)" >&2
fi

echo "[install-repo-intelligence] Serena (optional semantic code intelligence) — not installed by default."
echo "  See https://github.com/oraios/serena — install locally if you want LSP-style symbol search."

MCP_EXAMPLE="${REPO_ROOT}/.cursor/mcp.json.example"
if [[ -f "${MCP_EXAMPLE}" ]]; then
  echo "[install-repo-intelligence] Context7 MCP template: ${MCP_EXAMPLE}"
  echo "  Copy to ~/.cursor/mcp.json or merge into .cursor/mcp.json; set CONTEXT7_API_KEY locally."
fi

echo "[install-repo-intelligence] Done."

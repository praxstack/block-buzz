#!/usr/bin/env bash
# Install repo-level agent tooling: OpenSpec, Graphify, agent-browser CLI, Context7 MCP template.
# Idempotent — safe to re-run from cloud-agent-install or manually after clone.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck disable=SC1091
if [[ -f "${REPO_ROOT}/bin/activate-hermit" ]]; then
  . "${REPO_ROOT}/bin/activate-hermit"
fi
export PATH="${REPO_ROOT}/bin:${PATH}"

echo "[setup-agent-stack] OpenSpec (spec-driven change proposals)..."
if command -v openspec >/dev/null 2>&1; then
  echo "[setup-agent-stack] openspec already installed: $(openspec --version 2>/dev/null || openspec version 2>/dev/null || echo present)"
else
  npm install -g @fission-ai/openspec@latest
fi
if [[ ! -d "${REPO_ROOT}/openspec" ]]; then
  echo "[setup-agent-stack] Initializing OpenSpec in repo..."
  openspec init "${REPO_ROOT}" 2>/dev/null || openspec init 2>/dev/null || true
fi

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

echo "[setup-agent-stack] Graphify (code graph — optional)..."
if command -v uv >/dev/null 2>&1; then
  if ! command -v graphify >/dev/null 2>&1; then
    uv tool install graphifyy 2>/dev/null || echo "[setup-agent-stack] graphifyy install failed — skip or install manually" >&2
  fi
  if command -v graphify >/dev/null 2>&1; then
    graphify install --project 2>/dev/null || echo "[setup-agent-stack] graphify install --project skipped (non-fatal)" >&2
    if [[ -d "${REPO_ROOT}/.claude/skills/graphify" && ! -d "${REPO_ROOT}/.cursor/skills/graphify" ]]; then
      cp -a "${REPO_ROOT}/.claude/skills/graphify" "${REPO_ROOT}/.cursor/skills/graphify"
      echo "[setup-agent-stack] Copied graphify skill to .cursor/skills/"
    fi
  fi
else
  echo "[setup-agent-stack] Skipping Graphify (uv not found)" >&2
fi

MCP_EXAMPLE="${REPO_ROOT}/.cursor/mcp.json.example"
if [[ -f "${MCP_EXAMPLE}" ]]; then
  echo "[setup-agent-stack] Context7 MCP template: ${MCP_EXAMPLE}"
  if [[ ! -f "${REPO_ROOT}/.cursor/mcp.json" ]]; then
    echo "[setup-agent-stack] Copy .cursor/mcp.json.example → .cursor/mcp.json and set CONTEXT7_API_KEY locally"
  fi
fi

echo "[setup-agent-stack] Done."

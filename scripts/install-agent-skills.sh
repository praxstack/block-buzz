#!/usr/bin/env bash
# Install or refresh third-party Cursor agent skills into .cursor/skills/.
# Buzz-native skills stay in .agents/skills/ (desktop-screenshot, sprout-cli).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx is required (Node.js)." >&2
  exit 1
fi

SKILLS=(skills@latest)

# install_skillpack <repo> [--skill <name>|--skill '*'] [extra npx args...]
install_skillpack() {
  local repo="$1"
  shift
  echo "[install-agent-skills] Installing ${repo}..."
  npx "${SKILLS[@]}" add "${repo}" "$@" -y -a cursor --copy
}

echo "[install-agent-skills] Installing curated skill packs..."

# Layer 0 — discovery
install_skillpack vercel-labs/skills --skill find-skills

# Core methodology packs
install_skillpack mattpocock/skills
install_skillpack obra/superpowers
install_skillpack addyosmani/agent-skills
install_skillpack shadcn/improve

# Vercel UI / React
install_skillpack vercel-labs/agent-skills --skill '*'

# Security & audit (Trail of Bits — full pack)
install_skillpack trailofbits/skills --skill '*'

# Browser QA
install_skillpack vercel-labs/agent-browser --skill agent-browser

# Anthropic dev subset (curated — not creative/enterprise skills)
install_skillpack anthropics/skills \
  --skill skill-creator --skill mcp-builder --skill webapp-testing \
  --skill frontend-design --skill doc-coauthoring --skill web-artifacts-builder \
  --skill claude-api --skill discernment-nudge

# GitHub / Copilot high-value subset (curated — not full 400+ pack)
install_skillpack github/awesome-copilot \
  --skill acquire-codebase-knowledge --skill agent-skill-stack \
  --skill agent-owasp-compliance --skill agent-governance \
  --skill agentic-eval --skill ai-ready --skill anti-ui-slop \
  --skill architecture-blueprint-generator --skill codebase-memory-mcp \
  --skill codeql --skill conventional-commit \
  --skill github-issues --skill pr-dashboard

# Compound engineering workflow
install_skillpack EveryInc/compound-engineering-plugin --skill '*'

# Microsoft — Azure-agnostic dev subset only (not full 13-skill pack)
install_skillpack microsoft/skills \
  --skill frontend-design-review --skill github-issue-creator \
  --skill continual-learning

echo "[install-agent-skills] Installing GitHub Spec Kit skills (speckit-*)..."
if command -v uv >/dev/null 2>&1; then
  if ! command -v specify >/dev/null 2>&1; then
    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
  fi
  SPECKIT_TMP="$(mktemp -d)"
  (
    cd "${SPECKIT_TMP}"
    specify init --here --integration cursor-agent \
      --integration-options="--skills" --force --non-interactive >/dev/null
    cp -a "${SPECKIT_TMP}/.cursor/skills/speckit-"* "${REPO_ROOT}/.cursor/skills/"
  )
  rm -rf "${SPECKIT_TMP}"
else
  echo "[install-agent-skills] Skipping spec-kit (uv not found — install from https://docs.astral.sh/uv/)" >&2
fi

echo "[install-agent-skills] Installing gstack (review/QA/ship/plan workflows)..."
"${REPO_ROOT}/scripts/install-gstack-skills.sh"

echo "[install-agent-skills] Installing pstack from cursor/plugins..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 https://github.com/cursor/plugins.git "$TMP/plugins"
mkdir -p .cursor/skills
cp -a "$TMP/plugins/pstack/skills/." .cursor/skills/

echo "[install-agent-skills] Syncing npx-installed skills into .cursor/skills..."
for s in .agents/skills/*/; do
  [[ -d "$s" ]] || continue
  name=$(basename "$s")
  case "$name" in
    desktop-screenshot|sprout-cli) continue ;;
  esac
  rm -rf ".cursor/skills/$name"
  cp -a "$s" ".cursor/skills/$name"
  rm -rf "$s"
done

echo "[install-agent-skills] Cleaning stray agent directories from skills CLI..."
for d in .adal .aider-desk .augment .autohand .bob .codeartsdoer .codebuddy \
  .codemaker .codestudio .commandcode .continue .cortex .crush .devin .factory \
  .forge .grok .hermes .iflow .inferencesh .intersect .jazz .junie .kilocode \
  .kimchi .kiro .kode .lingma .mcpjam .minimax .moxby .mux .neovate .ona \
  .openhands .pi .pochi .posit .qoder .qwen .reasonix .roo .rovodev .tabnine \
  .terramind .tinycloud .trae .vibe .windsurf .zcode .zencoder agent data skills; do
  [[ -d "$d" ]] && rm -rf "$d"
done

echo ""
echo "[install-agent-skills] Optional post-install steps:"
echo "  1. Run /setup-matt-pocock-skills once (or read docs/agents/*.md if already configured)"
echo "  2. Run /setup-pstack to write ~/.cursor/rules/pstack-models.mdc"
echo "  3. agent-browser CLI (for live browser QA):"
echo "       npm install -g agent-browser && agent-browser install"
echo "  4. gstack refresh (if skills are stale): ./scripts/install-gstack-skills.sh"
echo "  5. Spec Kit full project scaffold (optional — skills already vendored):"
echo "       uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
echo "       specify init --here --integration cursor-agent --integration-options=\"--skills\""
echo ""
echo "[install-agent-skills] Done. $(find .cursor/skills -name SKILL.md | wc -l) skills in .cursor/skills/"

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
add() {
  npx "${SKILLS[@]}" add "$@" --all -y -a cursor --copy
}

echo "[install-agent-skills] Installing curated skill packs..."
add mattpocock/skills
add shadcn/improve
add obra/superpowers
add addyosmani/agent-skills
npx "${SKILLS[@]}" add vercel-labs/agent-skills \
  --skill vercel-react-best-practices --skill web-design-guidelines \
  -y -a cursor --copy

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

echo "[install-agent-skills] Optional: install gstack globally for Cursor (requires bun):"
echo "  git clone --depth 1 https://github.com/garrytan/gstack.git /tmp/gstack"
echo "  (cd /tmp/gstack && ./setup --host cursor)"
echo ""
echo "[install-agent-skills] Done. $(find .cursor/skills -name SKILL.md | wc -l) skills in .cursor/skills/"

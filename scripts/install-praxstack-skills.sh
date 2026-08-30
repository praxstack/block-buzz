#!/usr/bin/env bash
# Install curated praxstack/skills-and-personas content into block-buzz.
# Skills → .cursor/skills/  |  personas → docs/agents/personas/praxstack/
# Workflows → docs/agents/workflows/praxstack/
#
# Idempotent: shallow-clone (or reuse PRAXSTACK_SKILLS_REPO), copy with cp -aL.
# Does not install orchestrator overlap (kingmode, super-mode-core, apex) or
# personal/health packs — see docs/agents/praxstack-skills.md.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

SKILLS_DIR="${REPO_ROOT}/.cursor/skills"
PERSONAS_DIR="${REPO_ROOT}/docs/agents/personas/praxstack"
WORKFLOWS_DIR="${REPO_ROOT}/docs/agents/workflows/praxstack"
CACHE_DIR="${REPO_ROOT}/.cache/praxstack-skills-and-personas"
SRC_REPO="${PRAXSTACK_SKILLS_REPO:-}"

# Curated new-skills/ portfolio (engineering + standards; no methodology overlap)
PRAXSTACK_NEW_SKILLS=(
  constellation-team
  principal-engineer
  backend-system-design-expert
  qa-security-engineer
  devops-sre-engineer
  frontend-uiux-designer
  product-manager
  backend-architecture-standards
  frontend-excellence-standards
  security-compliance-standards
  backend-pe
  backend-pe-typescript
  frontend-pe
  spec-creator
  blueprint-creator
  frontend-design-excellence
)

# Additional portable skills from skills/ (not duplicated in new-skills/)
PRAXSTACK_LEGACY_SKILLS=(
  coding-agent-leadership-principles
  cross-agent-handoff
  superimprove
)

cleanup() {
  if [[ -n "${CLONE_TMP:-}" && -d "${CLONE_TMP}" ]]; then
    rm -rf "${CLONE_TMP}"
  fi
}
trap cleanup EXIT

resolve_source() {
  if [[ -n "${SRC_REPO}" && -d "${SRC_REPO}" ]]; then
    echo "[install-praxstack-skills] Using PRAXSTACK_SKILLS_REPO=${SRC_REPO}"
    SRC="${SRC_REPO}"
    return
  fi
  if [[ -d "${CACHE_DIR}/.git" ]]; then
    echo "[install-praxstack-skills] Updating cached clone ${CACHE_DIR}..."
    git -C "${CACHE_DIR}" fetch --depth 1 origin main 2>/dev/null || \
      git -C "${CACHE_DIR}" fetch --depth 1 origin master 2>/dev/null || true
    git -C "${CACHE_DIR}" checkout -q main 2>/dev/null || \
      git -C "${CACHE_DIR}" checkout -q master 2>/dev/null || true
    git -C "${CACHE_DIR}" pull --ff-only -q 2>/dev/null || true
    SRC="${CACHE_DIR}"
    return
  fi
  mkdir -p "${REPO_ROOT}/.cache"
  echo "[install-praxstack-skills] Shallow cloning praxstack/skills-and-personas..."
  git clone --depth 1 https://github.com/praxstack/skills-and-personas.git "${CACHE_DIR}"
  SRC="${CACHE_DIR}"
}

copy_skill_dir() {
  local from="$1"
  local name="$2"
  if [[ ! -d "${from}" ]]; then
    echo "[install-praxstack-skills] Warning: missing ${from}" >&2
    return 1
  fi
  rm -rf "${SKILLS_DIR}/${name}"
  cp -aL "${from}" "${SKILLS_DIR}/${name}"
}

copy_tree() {
  local from="$1"
  local dest="$2"
  if [[ ! -d "${from}" ]]; then
    echo "[install-praxstack-skills] Warning: missing ${from}" >&2
    return 1
  fi
  rm -rf "${dest}"
  mkdir -p "$(dirname "${dest}")"
  cp -aL "${from}" "${dest}"
}

resolve_source
NEW_SKILLS_ROOT="${SRC}/new-skills"
LEGACY_SKILLS_ROOT="${SRC}/skills"

mkdir -p "${SKILLS_DIR}" "${PERSONAS_DIR}" "${WORKFLOWS_DIR}"

installed=0
for name in "${PRAXSTACK_NEW_SKILLS[@]}"; do
  if copy_skill_dir "${NEW_SKILLS_ROOT}/${name}" "${name}"; then
    installed=$((installed + 1))
  fi
done

for name in "${PRAXSTACK_LEGACY_SKILLS[@]}"; do
  if copy_skill_dir "${LEGACY_SKILLS_ROOT}/${name}" "${name}"; then
    installed=$((installed + 1))
  fi
done

echo "[install-praxstack-skills] Installing personas (md-personas)..."
copy_tree "${SRC}/md-personas" "${PERSONAS_DIR}/md-personas"

echo "[install-praxstack-skills] Installing workflow prompts..."
copy_tree "${SRC}/prompts/high-end-operator" "${WORKFLOWS_DIR}/high-end-operator"
copy_tree "${SRC}/prompts/project-alignment" "${WORKFLOWS_DIR}/project-alignment"

if [[ -f "${SRC}/SAFETY.md" ]]; then
  cp -a "${SRC}/SAFETY.md" "${WORKFLOWS_DIR}/SAFETY.md"
fi

# Index doc shipped in-repo (not copied from source)
if [[ ! -f "${REPO_ROOT}/docs/agents/praxstack-skills.md" ]]; then
  echo "[install-praxstack-skills] Note: docs/agents/praxstack-skills.md missing (expected in repo)" >&2
fi

# Validate Buzz-native symlinks survived
for buzz_skill in desktop-screenshot sprout-cli; do
  target="${SKILLS_DIR}/${buzz_skill}/SKILL.md"
  if [[ -L "${target}" ]] && [[ -e "${target}" ]]; then
    : # expected Buzz-native symlink
  elif [[ -f "${target}" ]]; then
    echo "[install-praxstack-skills] Warning: ${buzz_skill} is no longer a symlink to Buzz-native source" >&2
  else
    echo "[install-praxstack-skills] Error: Buzz-native skill ${buzz_skill} missing or broken" >&2
    exit 1
  fi
done

broken="$(find "${SKILLS_DIR}" -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${broken}" != "0" ]]; then
  echo "[install-praxstack-skills] Error: ${broken} broken symlinks under .cursor/skills/" >&2
  find "${SKILLS_DIR}" -type l ! -exec test -e {} \; -print >&2
  exit 1
fi

total="$(find "${SKILLS_DIR}" -name SKILL.md | wc -l | tr -d ' ')"
echo "[install-praxstack-skills] Done. ${installed} praxstack skills copied; ${total} total SKILL.md in .cursor/skills/"

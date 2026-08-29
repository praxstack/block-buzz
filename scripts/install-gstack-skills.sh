#!/usr/bin/env bash
# Install gstack Cursor skills into .cursor/skills/ for project-level (cloud-agent) use.
# Clones garrytan/gstack, runs ./setup --host cursor, copies generated skills and
# runtime assets (bin, lib, browse) with symlinks dereferenced so paths are portable.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

SKILLS_DIR="${REPO_ROOT}/.cursor/skills"
GSTACK_REPO="${GSTACK_REPO:-}"
GSTACK_TMP=""

cleanup() {
  if [[ -n "${GSTACK_TMP}" && -d "${GSTACK_TMP}" ]]; then
    rm -rf "${GSTACK_TMP}"
  fi
}
trap cleanup EXIT

if [[ -n "${GSTACK_REPO}" && -d "${GSTACK_REPO}" ]]; then
  GSTACK_SRC="${GSTACK_REPO}"
  echo "[install-gstack-skills] Using existing clone: ${GSTACK_SRC}"
else
  GSTACK_TMP="$(mktemp -d)"
  GSTACK_SRC="${GSTACK_TMP}/gstack"
  echo "[install-gstack-skills] Cloning garrytan/gstack (shallow)..."
  git clone --depth 1 https://github.com/garrytan/gstack.git "${GSTACK_SRC}"
fi

if ! command -v bun >/dev/null 2>&1; then
  if [[ -x "${HOME}/.bun/bin/bun" ]]; then
    export PATH="${HOME}/.bun/bin:${PATH}"
  else
    echo "[install-gstack-skills] Error: bun is required. Install from https://bun.sh" >&2
    exit 1
  fi
fi

echo "[install-gstack-skills] Running gstack setup --host cursor (builds browse binary)..."
(
  cd "${GSTACK_SRC}"
  ./setup --host cursor -q
)

GENERATED="${GSTACK_SRC}/.cursor/skills"
if [[ ! -d "${GENERATED}" ]]; then
  echo "[install-gstack-skills] Error: ${GENERATED} not found after setup" >&2
  exit 1
fi

mkdir -p "${SKILLS_DIR}"

echo "[install-gstack-skills] Copying gstack-* skill directories..."
for skill_dir in "${GENERATED}"/gstack-*/; do
  [[ -d "${skill_dir}" ]] || continue
  name="$(basename "${skill_dir}")"
  rm -rf "${SKILLS_DIR}/${name}"
  cp -a "${skill_dir}" "${SKILLS_DIR}/${name}"
done

echo "[install-gstack-skills] Installing gstack runtime root (.cursor/skills/gstack/)..."
GSTACK_DEST="${SKILLS_DIR}/gstack"
rm -rf "${GSTACK_DEST}"
mkdir -p "${GSTACK_DEST}/browse" "${GSTACK_DEST}/gstack-upgrade" "${GSTACK_DEST}/review"

if [[ -f "${GENERATED}/gstack/SKILL.md" ]]; then
  cp -a "${GENERATED}/gstack/SKILL.md" "${GSTACK_DEST}/SKILL.md"
fi
if [[ -f "${GENERATED}/gstack-upgrade/SKILL.md" ]]; then
  cp -a "${GENERATED}/gstack-upgrade/SKILL.md" "${GSTACK_DEST}/gstack-upgrade/SKILL.md"
fi

# Dereference symlinks — setup links to the clone dir; cloud agents need real files.
for item in bin lib ETHOS.md; do
  if [[ -e "${GSTACK_SRC}/${item}" ]]; then
    cp -aL "${GSTACK_SRC}/${item}" "${GSTACK_DEST}/${item}"
  fi
done
if [[ -d "${GSTACK_SRC}/browse/dist" ]]; then
  cp -aL "${GSTACK_SRC}/browse/dist" "${GSTACK_DEST}/browse/dist"
fi
if [[ -d "${GSTACK_SRC}/browse/bin" ]]; then
  cp -aL "${GSTACK_SRC}/browse/bin" "${GSTACK_DEST}/browse/bin"
fi
for f in checklist.md TODOS-format.md; do
  if [[ -f "${GSTACK_SRC}/review/${f}" ]]; then
    cp -a "${GSTACK_SRC}/review/${f}" "${GSTACK_DEST}/review/${f}"
  fi
done
if [[ -f "${GSTACK_SRC}/supabase/config.sh" ]]; then
  mkdir -p "${GSTACK_DEST}/supabase"
  cp -aL "${GSTACK_SRC}/supabase/config.sh" "${GSTACK_DEST}/supabase/config.sh"
fi

SKILL_COUNT="$(find "${SKILLS_DIR}" -maxdepth 2 -name 'SKILL.md' -path '*/gstack*' | wc -l | tr -d ' ')"
echo "[install-gstack-skills] Done. ${SKILL_COUNT} gstack SKILL.md files in ${SKILLS_DIR}/"

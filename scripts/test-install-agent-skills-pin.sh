#!/usr/bin/env bash
# Falsifiable pin guard for scripts/install-agent-skills.sh:
# mutating SKILLS to skills@latest must refuse before any npx invocation.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="${repo_root}/scripts/install-agent-skills.sh"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/buzz-skills-pin-test.XXXXXX")"
trap 'rm -rf "${tmp}"' EXIT

failures=0
fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}
pass() {
  printf 'ok: %s\n' "$1"
}

if grep -q 'SKILLS=(skills@1.7.0)' "${src}"; then
  pass "production pin is skills@1.7.0"
else
  fail "production script is not pinned to skills@1.7.0"
fi

if grep -E 'SKILLS=\([^)]*latest' "${src}"; then
  fail "production SKILLS pin still contains latest"
else
  pass "production SKILLS pin does not contain latest"
fi

mkdir -p "${tmp}/scripts" "${tmp}/bin"
cp "${src}" "${tmp}/scripts/install-agent-skills.sh"
sed -i 's/skills@1\.7\.0/skills@latest/' "${tmp}/scripts/install-agent-skills.sh"

npx_log="${tmp}/npx-invoked"
cat > "${tmp}/bin/npx" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" > "${npx_log}"
exit 99
EOF
chmod +x "${tmp}/bin/npx"

set +e
output="$(
  PATH="${tmp}/bin:${PATH}" \
    bash "${tmp}/scripts/install-agent-skills.sh" 2>&1
)"
status=$?
set -e

if [[ "${status}" -eq 0 ]]; then
  fail "mutated latest pin exited 0"
elif [[ "${output}" == *'refuse unpinned'* ]]; then
  pass "mutated latest pin is refused"
else
  fail "mutated latest pin did not print refuse message (exit ${status})"
fi

if [[ -e "${npx_log}" ]]; then
  fail "fake npx was invoked; guard did not run before install"
else
  pass "fake npx was not reached"
fi

if [[ "${failures}" -ne 0 ]]; then
  printf '%s\n' "${output}" >&2
  exit 1
fi

echo "PASS: skills pin guard refuses latest before npx"

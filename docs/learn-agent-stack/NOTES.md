# Session Notes

Scratchpad for learning the agent stack. Add dated entries as you explore.

## 2026-08-30 — Bootstrap session

- **Branch truth:** `prax/gstack-setup-533e` does not exist in this fork. Cloud VMs resume on feature branches from prior agent runs (e.g. `prax/praxstack-skills-personas-a3ec`). Default branch is `main`.
- **PR #9 merged** — praxstack skills, personas, workflows now on `main` (commit `a12d71b5`).
- **PR #2** — stale draft; superseded by PRs #4–#7. Close manually (integration token cannot close PRs).
- **One methodology per task** — do not load kingmode + gstack + superpowers in one session.
- **Install order:** Hermit activate → `just setup` (or cloud-agent scripts) → `install-agent-skills.sh`.

## Open questions

- [ ] Context7 API key for local MCP
- [ ] Cursor Portal environment Save after next green build
- [ ] buzz-voice `libstdc++` for full unit test suite

## Commands to try

```bash
. ./bin/activate-hermit
./scripts/install-agent-skills.sh
just relay          # ws://localhost:3000
just desktop-dev    # Vite dev server
find .cursor/skills -name SKILL.md | wc -l
```

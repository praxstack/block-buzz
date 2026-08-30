# Learning Record 0001 — Session Bootstrap

**Date:** 2026-08-30  
**Repo:** praxstack/block-buzz  
**Branch at start:** `prax/praxstack-skills-personas-a3ec`  
**Branch at end:** `main`

## Objectives

- Understand why Cloud Agent was on a feature branch, not `main`.
- Merge remaining agent-stack work (PR #9).
- Scaffold teaching workspace for autonomous learning.

## What happened

| Event | Outcome |
| --- | --- |
| Branch audit | No `deb`, `dev`, or `prax/gstack-setup-533e` branches exist in this fork |
| PR #9 | Merged to `main` via admin merge (E2E flake was unrelated to PR diff) |
| PR #2 | Still open draft; close blocked by token permissions — user action required |
| Teaching workspace | Created `docs/learn-agent-stack/` |

## Key learnings

1. **Cloud Agents resume on the branch from the prior run**, not automatically on `main`. Multitask "Working 1" is a subagent in progress, not a branch name.
2. **Agent-stack PRs touch docs/skills only** — desktop smoke E2E failures are often pre-existing flakes, not regressions from skill installs.
3. **Install entry point** is `./scripts/install-agent-skills.sh` (calls gstack, praxstack, wshobson subsets).

## Follow-up

- [ ] User closes PR #2 manually
- [ ] Save Cloud Agent environment in Cursor Portal
- [ ] Set `CONTEXT7_API_KEY` and copy `.cursor/mcp.json.example`
- [ ] Lesson 0002: gstack review workflow hands-on

## References

- `docs/project-status-report.html`
- `.cursor/skills/README.md`
- `docs/agents/praxstack-skills.md`

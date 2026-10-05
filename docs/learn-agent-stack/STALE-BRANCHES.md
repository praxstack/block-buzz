# Stale `prax/*` remote branches

Inventory of `origin/prax/*` (and `imgbot`) as of **2026-10-05**. This
document is the operator checklist. It does **not** delete anything.

Do not fight ImgBot. Leave `imgbot` / PR #1 alone.

## Safe to delete (merged or superseded)

These remote branches had a merged or closed PR at inventory time. Do
not trust the dated SHAs in this file. Fetch first, then confirm the
**current** remote tip is already on `origin/main` before deleting:

```bash
git fetch origin main '<branch>'
git merge-base --is-ancestor "origin/<branch>" origin/main
git push origin --delete '<branch>'
```

If the ancestor check fails, the branch has new unmerged commits — leave
it alone and re-review.

| Remote branch | Last commit | PR | Status |
| --- | --- | --- | --- |
| `prax/praxstack-skills-personas-a3ec` | 2026-08-29 | [#9](https://github.com/praxstack/block-buzz/pull/9) | merged |
| `prax/gstack-skills-fix-a3ec` | 2026-08-29 | [#8](https://github.com/praxstack/block-buzz/pull/8) | merged |
| `prax/fix-cloud-agent-sudo-74e3` | 2026-08-29 | [#6](https://github.com/praxstack/block-buzz/pull/6) | merged |
| `prax/fix-dockerd-path-74e3` | 2026-08-29 | [#5](https://github.com/praxstack/block-buzz/pull/5) | merged (path-only; apt fallback is a later PR) |
| `prax/cloud-agent-env-74e3` | 2026-08-29 | [#4](https://github.com/praxstack/block-buzz/pull/4) | merged |
| `prax/cloud-agent-env-setup-a3ec` | 2026-08-29 | [#2](https://github.com/praxstack/block-buzz/pull/2) | closed as superseded |

## No PR (review before deleting)

| Remote branch | Last commit | Notes |
| --- | --- | --- |
| `prax/agent-stack-docs-a3ec` | 2026-08-30 | learn-agent-stack docs; likely already on `main` |
| `prax/agent-stack-2026-a3ec` | 2026-08-29 | Context7 / Graphify stack; confirm vs `main` before delete |

## Keep

| Remote branch | Why |
| --- | --- |
| `imgbot` | Open PR #1; do not fight the bot |
| `prax/prax-mode-a3ec` | Open PR #10 |
| `prax/sync-upstream-a3ec` | Active upstream merge |
| `prax/issue-*-a3ec` from 2026-10-05 | Active overnight work |

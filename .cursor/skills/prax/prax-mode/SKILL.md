---
name: prax-mode
description: "Prax's working style for autonomous Cloud VM delivery, spec-driven multi-agent review, DCO PRs onto main, and curated skill stacks. Use for Prax, /prax-mode, or requests to work in their style."
disable-model-invocation: true
---

# Prax mode

Rules for agents working as the user. Apply only when invoked by name or `/prax-mode`.

## Non-negotiables

- Overnight, `/autopilot`, "don't stop", "no pushback", or "I am going to sleep" means finish the authorized work. Infer defaults. Do not AskQuestion.
- Push from this Cloud VM. Do not hand the user local git steps.
- Every commit is `git commit -s` (DCO). Activate Hermit first (`. ./bin/activate-hermit`).
- Feature work lands as a PR against `main`. A leftover feature-branch checkout after merge is a defect. Sync `main` locally after merge. Name the real branch in every status report.
- Curate skills. Do not dump packs. One methodology per task. `.cursor/skills/README.md`.
- A skill is installed only if its `SKILL.md` exists and is not a stub. Verify before telling the user it works.
- Status the user will read later is honest HTML. Do not greenwash.
- Agent-facing prose follows `.cursor/skills/unslop/SKILL.md`. Skill files follow `.cursor/skills/skill-creator/SKILL.md`.

## Autonomy

**Do it.** Reversible work, MCP, subagents, extra compute, issue pickup, PR open, and CI fix loops proceed without asking.

**Pause** for force-push to `main`, secrets in the repo, data deletion, customer-facing messages, and merge when the current command forbids it (babysit or autopilot). When the user said merge and this run is not babysit, merge green PRs.

Do not ask "should I continue?" The user already authorized the loop.

## Process

Branch from fresh `origin/main`:

```
prax/<short-name>-<env-suffix>
```

Use the env suffix from the current Cloud Agent branch template. Lowercase only.

Prefer ManagePullRequest when that tool exists (`draft: false`, base `main`). If it is missing, `gh pr create --repo praxstack/block-buzz`. `gh` writes often 403 here. Push the branch anyway and report the exact error.

PR title uses Conventional Commits (`feat(agents): ...`). See `CONTRIBUTING.md`.

After a PR merges, check out `main` and pull. Call `SetActiveBranch` on every branch change. If the UI still shows a feature branch, say so. Cloud Agent resume leaves the workspace on the branch the run started on.

Babysit with `.cursor/skills/ce-babysit-pr/SKILL.md`. Autopilot means merge-ready, not merged, unless the user said merge.

Product work still follows `AGENTS.md` (VISION, tests, no `unsafe`, no new production `unwrap`).

## Spec-driven delivery

Non-trivial product or issue work, in order:

1. Spec first. One of `.cursor/skills/openspec-propose/SKILL.md`, `.cursor/skills/spec-creator/SKILL.md`, or superpowers `brainstorming` then `writing-plans`. Do not stack them.
2. Design approval. `.cursor/skills/constellation-team/SKILL.md` plus extra principal-engineer passes until the design is approved. Then the matching implementer (frontend or backend), then QA. Loop until review agrees. Do not ship a design one agent invented alone.
3. Independent code review before the PR is ready. `.cursor/skills/ce-code-review/SKILL.md` or `.cursor/skills/code-review/SKILL.md`.
4. Independent tasks in one plan go through `.cursor/skills/subagent-driven-development/SKILL.md`.

Codebase questions go through graphify first. `.cursor/skills/graphify/SKILL.md`.

Issues are on praxstack/block-buzz. `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`.

## Skills stack

Cloud Agents read project skills in `.cursor/skills/`, not only `~/.cursor`. Install with `scripts/install-agent-skills.sh` and `scripts/install-praxstack-skills.sh`. Idempotent. No broken gstack stubs.

Layer, one methodology per task:

discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn

Default implement layer is `/poteto-mode` (`.cursor/skills/poteto-mode/SKILL.md`). Do not stack poteto-mode with `ce-work` and superpowers TDD in the same session.

List a pack with `-l` before adding it. Skip full dumps (microsoft/skills, full wshobson, supabase/cloudflare/aws) unless the task needs that vendor.

Personal workflows: `docs/agents/praxstack-skills.md`.

## Reports

When the user asks for status, environment, "where are we", or HTML:

- Write a well-formed HTML5 file, usually `docs/project-status-report.html`.
- No Markdown in that artifact.
- State current branch vs `main`, open vs merged PRs, user-gated items (login, MCP keys, environment Save), CI truth, and subagent lag.
- Do not hide 403s, flakes, or parked checkouts.

A canvas is extra. It does not replace the HTML file.

## Review and verify

- Do not claim a command ran unless it did.
- Fix CI caused by this PR. Loop until green or report the exact blocker.
- Automated review (Bugbot and similar): fix real issues, dismiss noise with a reason. `.cursor/skills/ce-resolve-pr-feedback/SKILL.md`.
- UI changes: exercise the flow. `.cursor/skills/agent-browser/SKILL.md`, `.agents/skills/desktop-screenshot`.

## Writing the reply

Short sentences. Lead with the result (PR URL, branch, what merged). Tables for inventories. Honest blockers. No "let me know if".

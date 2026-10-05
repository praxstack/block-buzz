# Spec: prax-mode Cloud Agent skill

Status: APPROVED (design review round 1)

## Problem

Cloud Agents in this fork do not share one invocation path for Prax's
recurring conventions: overnight autonomy, DCO commits, PRs onto `main`,
spec-then-constellation review, curated skill stacks, and honest HTML
status. Each run invents process.

## Decision

Add opt-in skill `.cursor/skills/prax/prax-mode/SKILL.md` with
`disable-model-invocation: true`. Trigger only on Prax, `/prax-mode`, or
an explicit “work in their style” request.

The skill binds overnight/autopilot to finish authorized work, Hermit then
`git commit -s`, PRs onto `main` via ManagePullRequest when present,
spec-then-PE review with a 3-pass ceiling, graphify-first codebase
questions, and honest HTML status. Pause for force-push to `main`, secrets,
data deletion, customer-facing messages, and merge when the current command
forbids it.

## Tests

- Frontmatter sets `disable-model-invocation: true` and names `/prax-mode`.
- Skill is markdown only; no product runtime change.
- Invocation is opt-in (not auto-applied on every Cloud Agent turn).

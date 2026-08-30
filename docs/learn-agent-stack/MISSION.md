# Mission: Learn the Buzz Agent Stack

## Why this exists

`praxstack/block-buzz` is a fork of Block's Buzz monorepo extended into an **enterprise-grade agent development prototype**. The product (relay, desktop, mobile) is upstream Buzz. The fork's unique value is the **agent stack**: curated Cursor skills, Cloud Agent environment, gstack/pstack workflows, and praxstack personas — all installable and documented on `main`.

This learning workspace helps you understand that stack without reading 380+ skill files at once.

## What you will learn

1. **What the agent stack is** — layers from discover → spec → plan → implement → review → ship.
2. **How pieces connect** — Hermit toolchain, Cloud Agent scripts, skill installers, MCP templates.
3. **When to use what** — one methodology per task; avoid stacking competing orchestrators.
4. **How to operate** — install, invoke skills, run relay/desktop in Cloud Agent VMs.

## Who this is for

- Engineers onboarding to the fork for agent-assisted Buzz development.
- Cloud Agent operators validating environment setup.
- Contributors extending skills, personas, or install scripts.

## Success criteria

You can:

- Run `./scripts/install-agent-skills.sh` and explain what it installs.
- Start relay + desktop in a Cloud Agent VM (`just relay`, `just desktop-dev`).
- Pick the right skill for a task (e.g. gstack review vs praxstack constellation-team).
- Trace a workflow prompt from `docs/agents/workflows/praxstack/` to the skills it invokes.

## Start here

| Step | Artifact |
| --- | --- |
| 1 | [Lesson 0001](lessons/0001-what-is-the-agent-stack.html) |
| 2 | [Glossary](reference/glossary.html) |
| 3 | [Resources](RESOURCES.md) |
| 4 | [Session notes](learning-records/0001-session-bootstrap.md) |

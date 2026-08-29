# Praxstack personal skills, personas, and workflows

Curated content from [praxstack/skills-and-personas](https://github.com/praxstack/skills-and-personas) vendored into this repo for Cursor Cloud Agents and local development.

## Install or refresh

```bash
./scripts/install-praxstack-skills.sh
```

Runs automatically as part of `./scripts/install-agent-skills.sh` and `scripts/cloud-agent-install.sh`.

Override the source clone:

```bash
PRAXSTACK_SKILLS_REPO=/path/to/skills-and-personas ./scripts/install-praxstack-skills.sh
```

## What gets installed

### Skills (`.cursor/skills/`)

**Constellation team + standards (16 skills from `new-skills/`):**

| Skill | Role |
| --- | --- |
| `constellation-team` | Multi-role planning orchestrator |
| `principal-engineer` | Principal-level technical leadership |
| `backend-system-design-expert` | Backend architecture and system design |
| `qa-security-engineer` | QA and security engineering |
| `devops-sre-engineer` | DevOps / SRE |
| `frontend-uiux-designer` | Frontend UI/UX |
| `product-manager` | Product management |
| `backend-architecture-standards` | Backend architecture standards |
| `frontend-excellence-standards` | Frontend excellence standards |
| `security-compliance-standards` | Security and compliance |
| `backend-pe` | Backend PE orchestrator (routes to language variants) |
| `backend-pe-typescript` | TypeScript backend PE (desktop / Node surfaces) |
| `frontend-pe` | Frontend principal engineer |
| `spec-creator` | Spec and requirements documents |
| `blueprint-creator` | Blueprint / design documents |
| `frontend-design-excellence` | Design excellence for UI work |

**Portable skills from `skills/` (3):**

| Skill | Role |
| --- | --- |
| `coding-agent-leadership-principles` | Evidence, ownership, scoped authority for agents |
| `cross-agent-handoff` | Privacy-safe cross-agent transfers |
| `superimprove` | Bounded audit-fix-review-verify loop |

### Personas (`docs/agents/personas/praxstack/md-personas/`)

Single-file persona prompts: `CONSTELLATION-TEAM.md`, `FRONTEND-DESIGN.md`, `BACKEND-PE.md`, `FRONTEND-PE.md`, `KINGMODE.md`, `SUPER-MODE.md`, `ULTRATHINK-FRONTEND.md`, `GEMINI-KING-MODE.md`.

Persona files complement skills — reference them when you need role voice without loading a full skill pack.

### Workflows / goals (`docs/agents/workflows/praxstack/`)

Paste-prompt families (not Cursor Goals JSON):

| Path | Purpose |
| --- | --- |
| `high-end-operator/` | Lifecycle prompts: Think → Plan → Build → Review → Test → Ship → Reflect |
| `project-alignment/` | Reconstruct project, install packs, report-only QA |
| `SAFETY.md` | Mental-health skill scope and crisis resources |

Start with `high-end-operator/README.md` or `project-alignment/README.md`. **One methodology per task** — these invoke installed skills (gstack, superpowers, poteto-mode) by name; they do not replace them.

## Intentionally skipped (context rot or overlap)

| Category | Examples | Reason |
| --- | --- | --- |
| Orchestrator overlap | `kingmode`, `super-mode-core`, `apex-autonomous-mode`, `ultrathink-frontend` | Competes with `/poteto-mode`, gstack, `ce-work` |
| Personal intelligence | `chronicle`, `idea-capturer`, `baron-von-markup` | Personal journal / capture — not Buzz product work |
| Learning mentors | `teach-pro-max`, `techtutor`, `lecture-alchemist` | Large or education-specific; install ad hoc |
| Health | `mental-health-screening-companion` | See `SAFETY.md`; not vendored by default |
| Knowledge / Obsidian | `obsidian-cli`, `knowledge-packs/` | Personal knowledge-base automation |
| Transcript pipeline | `transcript-pipeline`, `transcribe-refiner` | Not Buzz core workflow |
| Legacy brain-ingest | `skills/brain-*`, `skills/ingest` | Superseded / personal ops |

### Optional one-off installs

```bash
# Full 41-skill portfolio (Claude Code global)
git clone https://github.com/praxstack/skills-and-personas.git /tmp/sap
bash /tmp/sap/new-skills/_audit/install.sh   # installs to ~/.claude/skills/

# Single public skills via skills.sh
npx skills add praxstack/skills-and-personas --skill teach-pro-max -y -a cursor --copy
npx skills add praxstack/skills-and-personas --skill coding-agent-leadership-principles -y -a cursor --copy
```

## How to invoke

| Workflow | How |
| --- | --- |
| Constellation planning | Ask for `constellation-team` skill or paste `md-personas/CONSTELLATION-TEAM.md` context |
| Backend review (Rust relay) | `backend-pe` skill — applies cross-language methodology directly for Rust |
| Desktop TypeScript | `backend-pe-typescript` or `frontend-pe` |
| Pre-PR agent discipline | `coding-agent-leadership-principles` or `superimprove` |
| High-end operator loop | Copy a prompt from `workflows/praxstack/high-end-operator/02-plan/SPEC.md` (etc.) into chat |
| Project realignment | `workflows/praxstack/project-alignment/ALIGN-INSTALL-QA.md` |

## Quality gates (source repo)

After updating the cached clone, optional validation:

```bash
cd .cache/praxstack-skills-and-personas/new-skills
python3 _audit/lint.py
python3 _audit/smoke_test.py   # expects ~/.claude/skills/ install
```

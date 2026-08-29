# Agent Skills Library

Curated third-party skills for Cursor Cloud Agents and local development. Buzz-native skills (`desktop-screenshot`, `sprout-cli`) live in `.agents/skills/`.

Reinstall or refresh everything:

```bash
./scripts/install-agent-skills.sh
```

One-time repo setup (already done for this fork; re-run after cloning):

```bash
# Wire issue tracker + triage labels + domain docs
/setup-matt-pocock-skills

# Write ~/.cursor/rules/pstack-models.mdc
/setup-pstack
```

---

## Layered architecture

Skills are organized into layers. **Activate one methodology per task** — do not stack competing planning/review skills in the same session.

```
discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn
    │            │              │         │          │          │           │         │       │
    ▼            ▼              ▼         ▼          ▼          ▼           ▼         ▼       ▼
 find-skills   interrogate    writing-  poteto-   gstack-    trailofbits  agent-   gstack-  ce-
 agent-skill-  to-spec        plans     mode      review     differential browser  ship     compound
 stack         brainstorming  ce-plan   super-    code-      review       desktop-         compound-
 acquire-      implement-spec subagent  powers    review     semgrep      screenshot       refresh
 codebase-     ce-brainstorm            tdd                  rust-review  ce-test-
 knowledge                                              agent-owasp
                                                        compliance
```

| Layer | When to use | Primary skills |
| --- | --- | --- |
| **Discover** | Unknown repo, need the right skill, onboarding | `find-skills`, `agent-skill-stack`, `acquire-codebase-knowledge` |
| **Interrogate / spec** | Vague ask → clear requirements | `interrogate`, `brainstorming`, `to-spec`, `ce-brainstorm`, `implement-spec` |
| **Plan** | Approved spec → executable plan | `writing-plans`, `ce-plan`, `subagent-driven-development` |
| **Implement** | Day-to-day coding (pick **one**) | `/poteto-mode` (pstack), superpowers TDD chain, `ce-work` |
| **Review** | Pre-merge quality gate | `gstack-review`, `code-review`, `ce-code-review`, `differential-review` |
| **Security** | Auth/crypto/infra changes | `trailofbits/*` (semgrep, rust-review, agent-owasp-compliance) |
| **Browser QA** | User-visible UI verification | `agent-browser`, `desktop-screenshot`, `ce-test-browser`, Playwright E2E |
| **Ship** | Release discipline | `gstack-ship`, `ce-commit-push-pr`, `finishing-a-development-branch` |
| **Learn** | Capture patterns for next time | `ce-compound`, `ce-compound-refresh`, `writing-skills` |

---

## Core 10 (start here)

| # | Skill / command | Pack | Role |
| --- | --- | --- | --- |
| 0 | `find-skills` | vercel-labs/skills | Discovery — locate skills for any task |
| 1 | `/poteto-mode` | pstack | Default rigorous implementation |
| 2 | `brainstorming` → `writing-plans` | superpowers | Spec-first when requirements are fuzzy |
| 3 | `triage` | mattpocock | Issue queue + label workflow |
| 4 | `gstack-review` | gstack (stubs) | Multi-perspective code review |
| 5 | `agent-browser` | vercel-labs/agent-browser | Live browser automation |
| 6 | `desktop-screenshot` | Buzz-native | Mock-bridge Playwright screenshots |
| 7 | `differential-review` | trailofbits | Security-focused diff review |
| 8 | `ce-work` | compound-engineering | Full compound engineering loop |
| 9 | `improve` | shadcn | Read-only codebase audit / roadmap |
| — | `speckit-specify` → `speckit-plan` | spec-kit | Alternative spec-first pipeline (pick one planning layer) |

---

## Which methodology when

| Situation | Use | Avoid stacking |
| --- | --- | --- |
| Routine feature / bugfix in Buzz | `/poteto-mode` | superpowers + ce-work + poteto-mode together |
| Requirements unclear | `brainstorming` → `writing-plans` → then implement | Starting to code before plan sign-off |
| Issue from GitHub queue | `triage` → `to-spec` → implement | ad-hoc `gh` without label vocabulary |
| Security-sensitive change (auth, crypto, relay) | `differential-review` + `rust-review` | Skipping Trail of Bits layer |
| Desktop/mobile UI change | `desktop-screenshot` or `agent-browser` | Full-page unscoped screenshots |
| Pre-PR review | `gstack-review` or `code-review` | Running every review skill in sequence |
| Release / merge | `gstack-ship` or `finishing-a-development-branch` | — |
| "What skills do I need?" | `find-skills` or `agent-skill-stack` | Installing random packs without `-l` first |

---

## Installed packs

| Pack | Skills | Install notes |
| --- | ---: | --- |
| **pstack** | ~45 | Cloned from `cursor/plugins`; run `/setup-pstack` for model overrides |
| **trailofbits/skills** | 81 | Full security/audit pack (`--skill '*'`); includes `rust-review`, `semgrep`, `differential-review` |
| **mattpocock/skills** | 37 | Run `/setup-matt-pocock-skills` once; reads `docs/agents/*.md` |
| **obra/superpowers** | 14 | Spec → plan → TDD execution chain |
| **addyosmani/agent-skills** | 25 | SDLC lifecycle gates |
| **vercel-labs/agent-skills** | 9 | React/Next UI performance + composition patterns |
| **vercel-labs/agent-browser** | 1 | Pairs with `desktop-screenshot` for live vs mock QA |
| **vercel-labs/skills** | 1 | `find-skills` discovery |
| **anthropics/skills** | 8 | Dev subset only: `skill-creator`, `mcp-builder`, `webapp-testing`, etc. |
| **github/awesome-copilot** | 13 | Curated: `github-issues`, `acquire-codebase-knowledge`, `codeql`, … |
| **EveryInc/compound-engineering** | 34 | `ce-work`, `ce-plan`, `ce-compound`, browser test, PR babysit |
| **shadcn/improve** | 1 | Read-only audit |
| **microsoft/skills** | 3 | Curated Azure-agnostic: `frontend-design-review`, `github-issue-creator`, `continual-learning` |
| **github/spec-kit** | 10 | `speckit-*` workflow (constitution → specify → plan → tasks → implement) |
| **gstack** | stubs | See gstack caveat below |

Buzz-native (`.agents/skills/`): `desktop-screenshot`, `sprout-cli`.

**Not installed (by design):**

| Pack | Reason |
| --- | --- |
| `supabase/agent-skills` | Buzz uses Postgres directly, not Supabase |
| `cloudflare/skills` | Not in Buzz stack |
| `aws/agent-toolkit-for-aws` | Not in Buzz stack |
| `microsoft/skills` (remainder) | Azure/Copilot/Windows-specific skills excluded from curated subset |
| Full `awesome-copilot` | 417 skills — context rot; 13-skill curated subset installed |
| Full `anthropics/skills` | Creative/enterprise subset excluded |
| `heilcheng/awesome-agent-skills` | Index only — see [More credible collections](#more-credible-collections) |

---

## gstack cursor caveat

[gstack](https://github.com/garrytan/gstack) (`/review`, `/qa`, `/ship`, `/browse`, `/cso`) requires a **global** install with bun:

```bash
git clone --depth 1 https://github.com/garrytan/gstack.git /tmp/gstack
(cd /tmp/gstack && ./setup --host cursor)
```

This repo ships **stub skills** under `.cursor/skills/gstack-*` so agents know the commands exist. Stubs document the workflow; a global install unlocks the full skill bodies. Optional — skip on Cloud Agents without bun.

---

## agent-browser + desktop screenshots

Two complementary browser QA paths:

| Tool | When | How |
| --- | --- | --- |
| **`desktop-screenshot`** | Buzz desktop UI (Tauri mock bridge) | `just desktop-screenshot --name foo` or Playwright E2E specs |
| **`agent-browser`** | Live web apps, staging, non-mock flows | CLI-driven Playwright automation |

**agent-browser CLI** (optional global install):

```bash
npm install -g agent-browser
agent-browser install          # downloads Chrome
agent-browser install --with-deps   # Linux: include system libraries
```

Verified working in Cloud Agent VMs (Chrome 152). On bare Linux hosts, use `--with-deps` if launch fails.

Pairing pattern: use `agent-browser` to drive a running `just desktop-dev` or staging URL for interactive QA; use `desktop-screenshot` for deterministic PR screenshots with seeded mock state.

---

## Per-pack install commands

The install script wraps these; run individually to refresh one pack:

```bash
# Discovery
npx skills add vercel-labs/skills --skill find-skills -y -a cursor --copy

# Full packs
npx skills add trailofbits/skills --skill '*' -y -a cursor --copy
npx skills add vercel-labs/agent-skills --skill '*' -y -a cursor --copy
npx skills add EveryInc/compound-engineering-plugin --skill '*' -y -a cursor --copy

# Curated subsets
npx skills add anthropics/skills --skill skill-creator --skill mcp-builder \
  --skill webapp-testing -y -a cursor --copy
npx skills add github/awesome-copilot --skill github-issues \
  --skill acquire-codebase-knowledge -y -a cursor --copy
```

After any `npx` install, sync from `.agents/skills/` into `.cursor/skills/` (the install script does this automatically).

---

## Repo configuration (`docs/agents/`)

| File | Purpose |
| --- | --- |
| `issue-tracker.md` | GitHub Issues on praxstack/block-buzz via `gh` |
| `triage-labels.md` | Five canonical triage label strings |
| `domain.md` | Single-context domain doc layout |

Referenced from `AGENTS.md` § Agent skills.

---

## More credible collections

| Repo | Why |
| --- | --- |
| [skills.sh](https://skills.sh) | Leaderboard + `npx skills find <query>` |
| [heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills) | Curated index |
| [wshobson/agents](https://github.com/wshobson/agents) | Multi-plugin orchestration |

Browse: `npx skills find <query>`

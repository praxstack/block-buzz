# Agent Skills Library

Curated third-party skills for Cursor Cloud Agents and local development. Buzz-native skills (`desktop-screenshot`, `sprout-cli`) live in `.agents/skills/`.

Reinstall or refresh everything:

```bash
./scripts/install-agent-skills.sh
```

## Primary workflows

| Goal | Start here | Source |
| --- | --- | --- |
| Rigorous engineering (default) | `/poteto-mode <task>` | [pstack](https://github.com/cursor/plugins/tree/main/pstack) |
| Configure pstack models | `/setup-pstack` | pstack |
| Spec → plan → TDD execution | superpowers chain: `brainstorming` → `writing-plans` → `subagent-driven-development` | [obra/superpowers](https://github.com/obra/superpowers) |
| Codebase audit / roadmap (read-only) | `improve` | [shadcn/improve](https://github.com/shadcn/improve) |
| Review / QA / ship | `gstack-review`, `gstack-qa`, `gstack-ship` | [garrytan/gstack](https://github.com/garrytan/gstack) (global `~/.cursor/skills`) |
| Triage / diagnose / architecture | `triage`, `diagnosing-bugs`, `improve-codebase-architecture` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| Production lifecycle gates | `using-agent-skills` meta + lifecycle skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| React / UI quality | `react-best-practices`, `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |

Run `/setup-matt-pocock-skills` once per repo to wire issue tracker and triage labels.

## Skill packs installed

### pstack (45 skills + playbooks)

Poteto's Cursor engineering stack: `poteto-mode`, `how`, `why`, `swarm`, `arena`, `architect`, `interrogate`, `tdd`, `unslop`, principles, and 22 playbooks under `poteto-mode/playbooks/`.

### obra/superpowers (14 skills)

`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch`, `dispatching-parallel-agents`, `writing-skills`, `using-superpowers`.

### mattpocock/skills (37 skills)

Engineering router (`ask-matt`), `code-review`, `diagnosing-bugs`, `tdd`, `triage`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, and more.

### addyosmani/agent-skills (25 skills)

Full SDLC: spec/plan/build/test/review/ship patterns, CI/CD, observability, security, performance, ADRs.

### shadcn/improve (1 skill)

Read-only codebase survey producing prioritized implementation plans for other agents.

### gstack (50+ skills, global install)

CEO review, design review, `/review`, `/qa`, `/ship`, `/browse`, security (`/cso`). Installed to `~/.cursor/skills/gstack*` via `./setup --host cursor` (requires bun).

### vercel-labs/agent-skills

`react-best-practices`, `web-design-guidelines`.

## More credible collections

| Repo | Why |
| --- | --- |
| [heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills) | Curated index + [skills.sh](https://skills.sh) leaderboard |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | React/Next.js performance and UI |
| [anthropics/skills](https://github.com/anthropics/skills) | Official Anthropic skill examples |
| [wshobson/agents](https://github.com/wshobson/agents) | Multi-plugin orchestration patterns |
| [Prathmesh2000/cursor_agent-orchestrator](https://github.com/Prathmesh2000/cursor_agent-orchestrator) | Role-based multi-agent workflows |

Browse installs: `npx skills find <query>` or https://skills.sh

## Overlap guidance

Several packs cover TDD, code review, and planning. Prefer:

1. **pstack `/poteto-mode`** for day-to-day rigorous implementation in Cursor
2. **superpowers** when you want explicit spec/plan/sign-off before coding
3. **gstack** for review, QA in a real browser, and release discipline
4. **mattpocock** for issue/triage integration and architecture diagnosis
5. **improve** when you want a read-only audit handoff, not implementation

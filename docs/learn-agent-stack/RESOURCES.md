# Agent Stack Resources

Curated links for the Buzz fork agent development prototype.

## This repository

| Resource | Path / command |
| --- | --- |
| Skills index | `.cursor/skills/README.md` |
| Praxstack skills guide | `docs/agents/praxstack-skills.md` |
| Install all skills | `./scripts/install-agent-skills.sh` |
| Install praxstack only | `./scripts/install-praxstack-skills.sh` |
| Install gstack | `./scripts/install-gstack-skills.sh` |
| Repo intelligence (OpenSpec, Graphify) | `./scripts/install-repo-intelligence.sh` |
| Full stack setup | `./scripts/setup-agent-stack.sh` |
| Cloud Agent install | `scripts/cloud-agent-install.sh` |
| Cloud Agent boot | `scripts/cloud-agent-start.sh` |
| Environment config | `.cursor/environment.json` |
| MCP template (Context7) | `.cursor/mcp.json.example` |
| Contributor guide | `AGENTS.md` |

## Upstream skill ecosystems

| Project | URL | Role |
| --- | --- | --- |
| **gstack** | https://github.com/gstack/gstack | Review, ship, compound engineering workflows |
| **pstack** | https://github.com/pstack/pstack | Model routing, poteto-mode orchestration |
| **praxstack skills** | https://github.com/praxstack/skills-and-personas | Personas, constellation team, high-end-operator workflows |
| **wshobson agents** | https://github.com/wshobson/agents | Specialist skills (subset installed) |
| **superpowers** | https://github.com/obra/superpowers | TDD, brainstorming, systematic debugging |
| **Matt Pocock skills** | https://github.com/mattpocock/skills | Issue tracker, triage, domain docs setup |

## Tooling

| Tool | Docs | Installed via |
| --- | --- | --- |
| **OpenSpec** | https://github.com/Fission-AI/OpenSpec | `install-repo-intelligence.sh` |
| **Graphify** | `uv tool install graphifyy` | `install-repo-intelligence.sh` |
| **Context7 MCP** | https://github.com/upstash/context7 | `npx @upstash/context7-mcp` (needs API key) |
| **agent-browser** | gstack | `setup-agent-stack.sh` |
| **Hermit** | https://github.com/cashapp/hermit | `. ./bin/activate-hermit` |

## Buzz upstream

| Resource | URL |
| --- | --- |
| Buzz OSS | https://github.com/block/buzz |
| Nostr NIPs | https://github.com/nostr-protocol/nips |
| Vision | `VISION.md` |
| Architecture | `ARCHITECTURE.md` |
| Testing | `TESTING.md` |

## Cursor Cloud Agents

| Resource | Notes |
| --- | --- |
| Environment setup skill | `~/.cursor/skills-cursor/env-setup/SKILL.md` |
| Save environment | Cursor Portal → Cloud Agent environment → Save after validating build |
| Status report | `docs/project-status-report.html` |

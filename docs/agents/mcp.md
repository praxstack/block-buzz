# Cursor MCP examples

Copy [`.cursor/mcp.json.example`](../../.cursor/mcp.json.example) to
`.cursor/mcp.json` (gitignored) and fill in any secrets locally. Do not
commit API keys.

## Context7

The example pins `@upstash/context7-mcp@4.1.1` (`npm view` on 2026-10-05).
Leave the version in the `npx` args; `@latest` is a moving tag.

Context7 is optional. `@upstash/context7-mcp@4.1.1` starts without
`CONTEXT7_API_KEY` and supports anonymous basic usage. The key is
optional: it raises rate limits and enables private-repository access.

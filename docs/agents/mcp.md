# Cursor MCP examples

Copy [`.cursor/mcp.json.example`](../../.cursor/mcp.json.example) to
`.cursor/mcp.json` (gitignored) and fill in any secrets locally. Do not
commit API keys.

## Context7

The example pins `@upstash/context7-mcp@4.1.1` (`npm view` on 2026-10-05).
Leave the version in the `npx` args; `@latest` is a moving tag.

Context7 is optional. An empty or missing `CONTEXT7_API_KEY` is fine —
the server is unused until a key is configured in the local MCP file.

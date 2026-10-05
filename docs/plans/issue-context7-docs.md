# Spec: pin Context7 MCP example

Status: APPROVED (design review round 1)

## Problem

`.cursor/mcp.json.example` runs `npx -y @upstash/context7-mcp` with no
version, so Cloud Agents pull whatever npm currently tags as latest.

## Decision

Pin `@upstash/context7-mcp@4.1.1` in the example and document the pin in
`docs/agents/mcp.md`. Do not commit secrets.

## Tests

- Example args include `@4.1.1` and do not use a bare unpinned package.

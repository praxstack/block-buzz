# Spec: #8016 call_webhook aborts remaining steps

Status: APPROVED (design review round 3)

## Problem

A `message_posted` workflow runs `send_message`, then `call_webhook`, then
another `send_message`. Only the first message appears. A webhook HTTP/DNS/SSRF
error is treated as a terminal `WorkflowError`, so `execute_steps` returns and
never runs later steps. `{{steps.hit.status}}` is never populated.

## Decision

`call_webhook` is a step, not a workflow abort. Network, DNS, SSRF, TLS, and
HTTP-client failures complete the step with `{status: 0, error, body: null}`
so following steps run and can branch on `steps.<id>.status`.

SSRF pinning still rejects private/reserved addresses. Prefer IPv4 among the
validated public addresses so dual-stack hosts (httpbin.org) do not pin to a
broken AAAA record.

JSON request bodies without an explicit Content-Type get `application/json`.

## Non-goals

Persisting CLI `workflows runs` history (separate visibility bug). Changing
the community write fence.

## Tests

- `select_ssrf_pin_ip` prefers IPv4, rejects mixed private answers
- webhook failure output is `{status: 0, error}` so remaining steps can read it

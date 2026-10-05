# Spec: document stale prax/* remotes

Status: APPROVED (design review round 1)

## Problem

Fork `origin` still carries merged 2026-08-29 Cloud Agent branches.
Operators (and later Cloud Agents) resume them by accident.

## Decision

Add `docs/learn-agent-stack/STALE-BRANCHES.md` with keep / delete
guidance. Do not delete remotes from this PR. Do not touch ImgBot.

## Tests

- Table lists merged PR numbers 4, 5, 6, 8, 9 and closed #2.
- ImgBot is in Keep.

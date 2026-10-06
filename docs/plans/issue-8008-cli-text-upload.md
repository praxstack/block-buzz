# Spec: #8008 CLI rejects text file uploads

Status: APPROVED (design review round 1)

## Problem

`buzz upload` / `messages send --file` sniff magic bytes and reject anything
outside jpeg/png/gif/webp/mp4. Unsniffable text becomes
`application/octet-stream` and fails. The relay file path already accepts
octet-stream and common text types (deny-list, not allow-list).

## Decision

Allow `application/octet-stream`, `text/plain`, `text/markdown`, `text/csv`,
`application/json`, and `text/html` in `ALLOWED_MIMES`. When sniffing finds
no signature, map `.txt` / `.md` / `.csv` / `.json` / `.html` to those types
and otherwise keep octet-stream. Size still uses `MAX_IMAGE_BYTES` for
non-video.

## Non-goals

Changing relay validation, Blossom auth, or adding a `--kinds` flag.

## Tests

- `ALLOWED_MIMES` contains octet-stream and the text types; still rejects
  `application/x-msdownload`.
- Extension fallback maps `.txt` to `text/plain` and unknown to octet-stream.

# Spec: #7928 buzz-pair nsec payload is not Desktop identity JSON

Status: APPROVED (design review round 1)

## Problem

Desktop Send identity transfers Custom JSON `{relayUrl, pubkey, nsec}` where
`relayUrl` is the HTTPS API origin. `buzz-pair source --nsec` always sends
`PayloadType::Nsec` (raw bech32). A Desktop target therefore cannot import a
CLI pairing as a usable community identity.

## Decision

Add `--app-relay <http(s) origin>`. When set, source emits Desktop-shaped
Custom JSON with that origin as `relayUrl`, the key's hex pubkey, and nsec.
Bare `--nsec` without `--app-relay` stays CLI-to-CLI `PayloadType::Nsec`.
`--relay` remains the WebSocket used for the pairing session.

## Non-goals

Changing Desktop pairing, NIP-AB crypto, or defaulting `--app-relay` from
`--relay`.

## Tests

- `--app-relay https://community.example` + nsec yields Custom JSON with
  matching `relayUrl`, 64-char `pubkey`, and the same `nsec`.
- Without `--app-relay`, payload type is Nsec and the body is the raw nsec.
- Non-http `--app-relay` is an error.

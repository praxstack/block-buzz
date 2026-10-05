# Spec: buzz-voice Linux libstdc++ link

Status: APPROVED (design review round 1)

## Problem

`cargo test -p buzz-voice` on Linux fails at link time: `sherpa-onnx` and
`ort` ship C++ objects, but rustc does not pass `-lstdc++` for this crate.

## Decision

Add a package `build.rs` that, on `target_os = linux`, emits
`-Wl,--no-as-needed` and `dylib=stdc++`. Do not put this in workspace
`.cargo/config.toml` (would affect every crate).

## Tests

- `cargo test -p buzz-voice --lib` must link on Linux.

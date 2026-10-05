# Spec: buzz-voice Linux libstdc++ link

Status: APPROVED (design review round 1)

## Problem

`cargo test -p buzz-voice` on Linux fails at link time: `sherpa-onnx` and
`ort` ship C++ objects, but rustc does not pass `-lstdc++` for this crate.

## Decision

Package `build.rs` asks `g++ -print-file-name=libstdc++.so` for the
GCC libdir (Hermit rust-lld does not search it), then emits
`-Wl,--no-as-needed` and `dylib=stdc++` on Linux only.

## Tests

- `cargo test -p buzz-voice --lib` must link on Linux.

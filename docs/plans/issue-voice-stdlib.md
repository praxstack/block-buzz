# Spec: buzz-voice Linux libstdc++ link

Status: APPROVED (design review round 1)

## Problem

`cargo test -p buzz-voice` on Linux fails at link time: `sherpa-onnx` and
`ort` ship C++ objects, but rustc does not pass `-lstdc++` for this crate.

## Decision

Package `build.rs` asks the TARGET/CXX C++ driver (via `cc`) for
`-print-file-name=libstdc++.so`, emits that GCC libdir as
`rustc-link-search` (Hermit rust-lld does not search it), then emits
`-Wl,--push-state,--no-as-needed,-lstdc++,--pop-state` on Linux only.
Discovery failure fails the build; CXX/PATH/TARGET invalidate the cache.

## Tests

- `cargo test -p buzz-voice --lib` must link on Linux.
- Lib tests `include_str!` the production `build.rs` so dropping the
  search-path, target compiler, rerun keys, failure propagation, or
  `--no-as-needed` wrapping fails without a rust-lld CI lane (CI uses mold).

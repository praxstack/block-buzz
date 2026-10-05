//! Linux unit tests and binaries that pull in `sherpa-onnx` / `ort` C++
//! objects fail to link unless libstdc++ is on the rustc link line.

use std::path::Path;
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    if target_os != "linux" {
        return;
    }

    // Hermit's rustc uses rust-lld, which does not search GCC's private
    // libdir. The unversioned `libstdc++.so` linker script lives there.
    if let Some(dir) = gcc_libstdcxx_dir() {
        println!("cargo:rustc-link-search=native={dir}");
    }

    // `--no-as-needed` keeps the C++ runtime even when the Rust crate
    // itself has no undefined C++ symbols; sherpa-onnx still needs it.
    println!("cargo:rustc-link-arg=-Wl,--no-as-needed");
    println!("cargo:rustc-link-lib=dylib=stdc++");
}

fn gcc_libstdcxx_dir() -> Option<String> {
    let output = Command::new("g++")
        .args(["-print-file-name=libstdc++.so"])
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    let printed = String::from_utf8(output.stdout).ok()?;
    let path = Path::new(printed.trim());
    if !path.exists() {
        return None;
    }
    path.parent()
        .map(|dir| dir.to_string_lossy().into_owned())
        .filter(|dir| !dir.is_empty())
}

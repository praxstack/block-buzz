//! Linux unit tests and binaries that pull in `sherpa-onnx` / `ort` C++
//! objects fail to link unless libstdc++ is on the rustc link line.

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    if target_os == "linux" {
        // `--no-as-needed` keeps the C++ runtime even when the Rust crate
        // itself has no undefined C++ symbols; sherpa-onnx still needs it.
        println!("cargo:rustc-link-arg=-Wl,--no-as-needed");
        println!("cargo:rustc-link-lib=dylib=stdc++");
    }
}

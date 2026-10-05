//! Linux unit tests and binaries that pull in `sherpa-onnx` / `ort` C++
//! objects fail to link unless libstdc++ is on the rustc link line.

use std::env;
use std::ffi::OsStr;
use std::path::{Path, PathBuf};
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    if let Err(err) = configure_linux_libstdcxx() {
        panic!("{err}");
    }
}

fn configure_linux_libstdcxx() -> Result<(), String> {
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    if target_os != "linux" {
        return Ok(());
    }

    // PATH / CXX / TARGET changes must invalidate the cached -L directory.
    println!("cargo:rerun-if-env-changed=CXX");
    println!("cargo:rerun-if-env-changed=CC");
    println!("cargo:rerun-if-env-changed=TARGET");
    println!("cargo:rerun-if-env-changed=HOST");
    println!("cargo:rerun-if-env-changed=PATH");

    let (mut print_lib, compiler_path) = libstdcxx_compiler()?;
    println!("cargo:rerun-if-changed={}", compiler_path.display());
    print_lib.arg("-print-file-name=libstdc++.so");
    let dir = libstdcxx_search_dir(&mut print_lib, &compiler_path)?;
    println!("cargo:rustc-link-search=native={dir}");

    // rustc-link-lib lands in the as-needed native-lib group; rustc-link-arg
    // is appended later. Emit both the flag and -lstdc++ as one late -Wl
    // group so --no-as-needed applies to this library.
    println!("cargo:rustc-link-arg=-Wl,--push-state,--no-as-needed,-lstdc++,--pop-state");
    Ok(())
}

/// Prefer `CXX`, then a TARGET-aware `cc` driver when cross-compiling, then
/// host `g++`. Clang's `c++` prints `libstdc++.so` unchanged and cannot
/// locate GCC's private libdir for rust-lld.
fn libstdcxx_compiler() -> Result<(Command, PathBuf), String> {
    if let Ok(cxx) = env::var("CXX") {
        let cxx = cxx.trim();
        if !cxx.is_empty() {
            return Ok((Command::new(cxx), PathBuf::from(cxx)));
        }
    }

    let target = env::var("TARGET").unwrap_or_default();
    let host = env::var("HOST").unwrap_or_default();
    if !target.is_empty() && target != host {
        let compiler = cc::Build::new().cpp(true).get_compiler();
        let path = compiler.path().to_path_buf();
        return Ok((compiler.to_command(), path));
    }

    Ok((Command::new("g++"), PathBuf::from("g++")))
}

fn libstdcxx_search_dir(cmd: &mut Command, compiler_path: &Path) -> Result<String, String> {
    let output = cmd.output().map_err(|err| {
        format!(
            "buzz-voice: failed to invoke {} -print-file-name=libstdc++.so: {err}",
            compiler_display(compiler_path)
        )
    })?;
    if !output.status.success() {
        return Err(format!(
            "buzz-voice: {} -print-file-name=libstdc++.so failed ({:?}): {}",
            compiler_display(compiler_path),
            output.status,
            String::from_utf8_lossy(&output.stderr).trim()
        ));
    }
    let printed = String::from_utf8(output.stdout).map_err(|_| {
        format!(
            "buzz-voice: {} -print-file-name=libstdc++.so wrote non-UTF-8",
            compiler_display(compiler_path)
        )
    })?;
    let printed = printed.trim();
    // GCC prints the input name unchanged when it cannot resolve the file.
    if printed.is_empty() || printed == "libstdc++.so" {
        return Err(format!(
            "buzz-voice: {} did not resolve libstdc++.so",
            compiler_display(compiler_path)
        ));
    }
    let path = Path::new(printed);
    if !path.exists() {
        return Err(format!(
            "buzz-voice: {} reported libstdc++ at {}, which does not exist",
            compiler_display(compiler_path),
            path.display()
        ));
    }
    let dir = path.parent().ok_or_else(|| {
        format!(
            "buzz-voice: {} reported libstdc++ at {} with no parent directory",
            compiler_display(compiler_path),
            path.display()
        )
    })?;
    let dir = dir.to_string_lossy();
    if dir.is_empty() {
        return Err(format!(
            "buzz-voice: {} reported an empty libstdc++ directory",
            compiler_display(compiler_path)
        ));
    }
    Ok(dir.into_owned())
}

fn compiler_display(path: &Path) -> String {
    if path.as_os_str() == OsStr::new("g++") {
        "g++".to_string()
    } else {
        path.display().to_string()
    }
}

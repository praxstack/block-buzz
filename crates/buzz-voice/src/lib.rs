//! Reusable local voice primitives for Buzz.

pub mod imported;
pub mod pocket;

pub use pocket::{
    april_model_info, load_text_to_speech, load_voice_style, PocketModelInfo, PocketTts,
    VoiceStyle, DEFAULT_VOICE, SAMPLE_RATE, VOICE_FILE_EXT,
};

/// One immutable artifact required by the April Pocket bundle.
///
/// `filename` is the bundle-relative file name, `sha256` pins its contents,
/// `size_bytes` supports download progress and validation, and `quantized`
/// identifies the INT8 components.
pub type PocketModelArtifact = pocket::PocketModelArtifact;

/// Language bundle selected from the pinned export.
pub const APRIL_BUNDLE_ID: &str = pocket::APRIL_BUNDLE_ID;
/// Pinned upstream export repository.
pub const APRIL_MODEL_ID: &str = pocket::APRIL_MODEL_ID;
/// Pinned revision containing the April bundle.
pub const APRIL_MODEL_REVISION: &str = pocket::APRIL_MODEL_REVISION;

#[cfg(test)]
mod tests {
    #[test]
    fn linux_link_includes_voice_crate() {
        assert!(!super::APRIL_BUNDLE_ID.is_empty());
        assert!(!super::APRIL_MODEL_ID.is_empty());
    }

    /// Production `build.rs` — not this test module. Removing the rust-lld
    /// search-path / `--no-as-needed` contract must fail these assertions.
    fn linux_link_build_rs() -> &'static str {
        include_str!("../build.rs")
    }

    #[test]
    fn linux_libstdcxx_uses_target_cxx_driver() {
        let src = linux_link_build_rs();
        assert!(
            src.contains("env::var(\"CXX\")"),
            "explicit CXX must win over the host driver"
        );
        assert!(
            src.contains("env::var(\"TARGET\")")
                && src.contains("env::var(\"HOST\")")
                && src.contains("cc::Build::new()")
                && src.contains(".cpp(true)"),
            "cross TARGET must use cc's TARGET-aware C++ driver, not host g++"
        );
        assert!(
            src.contains("Command::new(\"g++\")"),
            "native Linux must call g++; clang c++ does not resolve libstdc++.so"
        );
    }

    #[test]
    fn linux_libstdcxx_invalidates_cached_gcc_path() {
        let src = linux_link_build_rs();
        for key in ["CXX", "CC", "TARGET", "HOST", "PATH"] {
            let needle = format!("cargo:rerun-if-env-changed={key}");
            assert!(src.contains(&needle), "missing {needle}");
        }
        assert!(
            src.contains("cargo:rerun-if-changed={}") && src.contains("compiler_path.display()"),
            "the selected C++ driver path must be a rerun input"
        );
    }

    #[test]
    fn linux_libstdcxx_propagates_discovery_failure() {
        let src = linux_link_build_rs();
        assert!(
            src.contains("configure_linux_libstdcxx()") && src.contains("panic!(\"{err}\")"),
            "Linux libstdc++ discovery errors must fail the build script"
        );
        assert!(
            src.contains("libstdcxx_search_dir(") && src.contains("did not resolve libstdc++.so"),
            "an unresolved -print-file-name result must not become a silent skip"
        );
    }

    #[test]
    fn linux_libstdcxx_no_as_needed_wraps_the_library() {
        let src = linux_link_build_rs();
        assert!(
            src.contains("cargo:rustc-link-search=native={dir}"),
            "rust-lld needs GCC's private libdir on the search path"
        );
        // Split so a later edit cannot satisfy the flag and the lib in
        // separate rustc-link-arg / rustc-link-lib lines.
        let wrapped = concat!(
            "cargo:rustc-link-arg=-Wl,--push-state,--no-as-needed,",
            "-lstdc++,--pop-state"
        );
        assert!(
            src.contains(wrapped),
            " --no-as-needed must apply to -lstdc++ in one -Wl group"
        );
        assert!(
            !src.contains("cargo:rustc-link-lib=dylib=stdc++"),
            "rustc-link-lib places -lstdc++ in the as-needed native-lib group"
        );
    }
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Toolchain
    rustup

    # Cargo extensions
    cargo-edit
    cargo-expand
    cargo-features-manager
    cargo-generate
    cargo-mobile2
    cargo-outdated
    cargo-tauri
    cargo-watch

    # WebAssembly
    trunk
    wasm-pack

    # Database ORM CLI
    diesel-cli

    # Frameworks
    perseus-cli

    # Build caching
    sccache

    # Benchmarking
    hyperfine
  ];
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';
}

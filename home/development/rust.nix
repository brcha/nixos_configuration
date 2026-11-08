{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.rust {
    home.packages = with pkgs; [
      # Toolchain
      rustup

      # Cargo extensions
      cargo-generate

      # Build caching
      sccache
    ];
    home.file.".cargo/config.toml".text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
    '';
  };
}

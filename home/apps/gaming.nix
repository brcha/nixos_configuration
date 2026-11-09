{ pkgs, lib, config, ... }:

{
  # Steam and Proton are Linux-only
  config = lib.mkIf (config.my.apps.gaming && pkgs.stdenv.isLinux) {
    home.packages =
      let
        steam = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            vulkan-tools
            vulkan-loader
            mesa-demos
            gtk3
            gtk3-x11
            ocl-icd
            librsvg
          ];
        };
      in
      [
        steam
        # steam-run, for running non-Nix binaries in Steam's FHS environment
        steam.run
        pkgs.protontricks
      ];
  };
}

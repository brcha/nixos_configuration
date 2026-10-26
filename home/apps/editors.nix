{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.editors {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # AI-native editor
      unstable.zed-editor

      # Neovim GUI
      neovide
    ]);
  };
}

{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.editors {
    home.packages = available (with pkgs; [
      # AI-native editor
      unstable.zed-editor

      # Neovim GUI
      neovide
    ]);
  };
}

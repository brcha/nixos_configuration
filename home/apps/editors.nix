{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.editors {
    home.packages = available (with pkgs; [
      # AI-native editors
      unstable.zed-editor
      unstable.code-cursor

      # Neovim GUI
      neovide
    ]);
  };
}

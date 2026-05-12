{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # AI coding assistants
    claude-desktop.claude-desktop-fhs
    unstable.claude-code
    unstable.opencode

    # AI-native editor
    unstable.zed-editor
  ];
}

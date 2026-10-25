# Feature switches shared by NixOS and home-manager. On NixOS the machine sets
# them and nixosModules.home forwards them to the user; standalone home bundles
# set them directly.
{ config, lib, ... }:

let
  # A group switch whose children default to it
  group = groupName: description: children: {
    enable = lib.mkEnableOption description;
  } // lib.genAttrs children (name: lib.mkOption {
    type = lib.types.bool;
    default = config.my.${groupName}.enable;
    defaultText = lib.literalExpression "config.my.${groupName}.enable";
    description = "Whether to enable ${groupName} ${name} (defaults to my.${groupName}.enable).";
  });
in
{
  options.my = {
    hyprland.enable = lib.mkEnableOption "the Hyprland session";
    kde.enable = lib.mkEnableOption "the KDE Plasma session";

    dev = group "dev" "all development modules" [
      "ai"
      "cpp"
      "databases"
      "devops"
      "git"
      "git-tools"
      "go"
      "haskell"
      "jetbrains"
      "neovim"
      "python"
      "rust"
      "tools"
      "vcs"
      "vscode"
      "web"
    ];

    apps = group "apps" "all application modules" [
      "cloud-storage"
      "communication"
      "firefox"
      "fonts"
      "gaming"
      "graphics"
      "livecoding"
      "multimedia"
      "productivity"
      "security"
    ];
  };
}

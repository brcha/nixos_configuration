# Feature switches shared by NixOS and home-manager. On NixOS the machine sets
# them and nixosModules.home forwards them to the user; standalone home bundles
# set them directly.
{ config, lib, ... }:

let
  group = import ./group.nix lib config;
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
      "neovim"
      "python"
      "rust"
      "tools"
      "vcs"
      "web"
    ];

    apps = group "apps" "all application modules" [
      "cloud-storage"
      "communication"
      "dev-tools"
      "editors"
      "firefox"
      "fonts"
      "gaming"
      "graphics"
      "jetbrains"
      "livecoding"
      "multimedia"
      "networking"
      "productivity"
      "security"
      "system"
      "vscode"
    ];
  };
}

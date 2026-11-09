{ ... }:

{
  flake = {
    nixosModules = {
      gui.imports = [
        ./options.nix
        ./appimage.nix
        ./flatpak.nix
        ./fonts.nix
        ./ssh-agent.nix
        ./torrents.nix
        # ./hyprland.nix
      ];

      kde.imports = [
        ./kde.nix
      ];

      hyprland.imports = [
        ./hyprland.nix
      ];
    };
  };
}

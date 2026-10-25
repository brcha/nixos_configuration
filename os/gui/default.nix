{ ... }:

{
  flake = {
    nixosModules = {
      gui.imports = [
        ./flatpak.nix
        ./fonts.nix
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

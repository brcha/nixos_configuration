{ self, config, ... }:

{
  flake = {
    guiModules = {
      common.imports = [
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

      default.imports = [
        self.guiModules.common
      ];
    };
  };
}

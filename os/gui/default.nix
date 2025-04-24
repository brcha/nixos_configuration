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

      default.imports = [
        self.guiModules.common
      ];
    };
  };
}

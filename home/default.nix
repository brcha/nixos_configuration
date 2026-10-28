{ self, inputs, lib, ... }:

{
  flake = {
    homeModules = {
      # For use both in NixOS, WSL and Mac OS X
      common = {
        home.stateVersion = "23.11";
        imports = [
          ../options
          ../lib/available.nix
          ./sops.nix
          ./development
          ./apps
          ./tools
        ];
      };

      common-linux = {
        imports = [
          self.homeModules.common
        ];
      };

      # The platform bundles choose the switches; a host can still override them
      common-darwin = {
        imports = [
          self.homeModules.common
        ];
        my = {
          dev.enable = lib.mkDefault true;
          apps = {
            enable = lib.mkDefault true;
            jetbrains = lib.mkDefault false;
            vscode = lib.mkDefault false;
          };
        };
      };

      # WSL runs without a GUI, so no desktop apps and no hardware tools
      common-wsl = {
        imports = [
          self.homeModules.common
        ];
        my = {
          dev.enable = lib.mkDefault true;
          apps.enable = lib.mkDefault false;
          tools.hardware = lib.mkDefault false;
        };
      };
    };
  };
}

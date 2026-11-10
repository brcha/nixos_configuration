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
          inputs.nix-index-database.homeModules.nix-index
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
          };
          # The Mac has a small drive and does no TeX work
          tools.tex = lib.mkDefault false;
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

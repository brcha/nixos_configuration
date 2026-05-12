{ self, inputs, ... }:

{
  flake = {
    homeModules = {
      # For use both in NixOS, WSL and Mac OS X
      common = {
        home.stateVersion = "23.11";
        imports = [
          ./sops.nix
          #./vscode.nix
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

      common-darwin = {
        imports = [
          self.homeModules.common
        ];
      };

      common-wsl = {
        imports = [
          self.homeModules.common
        ];
      };
    };
  };
}

{ self, inputs, ... }:

{
  flake = {
    homeModules = {
      # For use both in NixOS, WSL and Mac OS X
      common = {
        home.stateVersion = "23.11";
        imports = [
          ./sops.nix
          ./shell.nix
          ./git.nix
          ./neovim.nix
          ./vscode.nix
          ./development/python.nix
          ./development/rust.nix
          ./firefox.nix
          ./therest_to_be_modularized.nix
          ./kde.nix
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

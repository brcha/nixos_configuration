{ self, config, flake, ... }:
let
  inherit (flake) inputs;
in
{
  flake = {
    nixosModules = {
      common.imports = [
        # What works for Mac OS X and WSL (as well as NixOS, ofc)
        ./sops.nix
        ./nix.nix
        ./users.nix
        ./zsh.nix
      ];

      my-config = {
        users.users.${config.people.me}.isNormalUser = true;
        home-manager.users.${config.people.me} = {
          imports = [
            self.homeModules.common-linux
          ];
        };
      };

      linux.imports = [
        ./base.nix
        ./openssh.nix
      ];

      default.imports = [
        self.nixosModules.my-config
        self.nixosModules.common
      ];
    };
  };
}

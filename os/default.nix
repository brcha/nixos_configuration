{ self, config, inputs, ... }:
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

      # Opt-in per machine: a server without a user environment does not import it
      home = {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
          users.${config.people.me}.imports = [
            self.homeModules.common-linux
          ];
        };
      };

      linux.imports = [
        ./base.nix
        ./firewall.nix
        ./openssh.nix
      ];

      hardware.imports = [
        ./hardware
      ];

      virtualisation.imports = [
        ./virtualisation
      ];

      default.imports = [
        self.nixosModules.common
      ];
    };
  };
}

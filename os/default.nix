{ self, config, inputs, ... }:
let
  me = config.people.me;
in
{
  flake = {
    nixosModules = {
      common.imports = [
        # What works for Mac OS X and WSL (as well as NixOS, ofc)
        ../options
        ./sops.nix
        ./nix.nix
        ./users.nix
        ./zsh.nix
      ];

      # Opt-in per machine: a server without a user environment does not import it
      home = { config, ... }: {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
          users.${me} = {
            imports = [
              self.homeModules.common-linux
            ];
            # The machine sets the shared switches once; the user gets the same values
            my = { inherit (config.my) hyprland kde dev apps; };
          };
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

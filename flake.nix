{
  description = "Brcha's NixOS configuration";

  inputs = {
    # NixOS Packages
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    # Utility for nicer organisation of files
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixos-unified = {
      url = "github:srid/nixos-unified";
    };

    # Home manager (using unstable nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets managment
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

    # For devshell to format
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } (
    { withSystem, lib, ... }: {

      systems = [ "x86_64-linux" ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nixos-unified.flakeModule
        ./users
        ./os
        ./os/gui
        ./home
      ];

      perSystem = { inputs', self', pkgs, config, ... }: {
        # Treefmt config
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
        };
        # Define devShell for easier development
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          packages = with pkgs; [
            just
            sops
          ];
        };
        # Helper apps
        apps = {
          flakeGitVars = {
            type = "app";
            program = pkgs.writeShellScriptBin "flakeGitVars" ''
              echo "flake: ${inputs.self}"
              echo "lastModified: ${builtins.toString (inputs.self.lastModified or "empty")}"
              echo "rev: ${builtins.toString (inputs.self.rev or "empty")}"
              echo "dirtyRev: ${builtins.toString (inputs.self.dirtyRev or "empty")}"
              echo "shortRev: ${builtins.toString (inputs.self.shortRev or "empty")}"
              echo "dirtyShortRev: ${builtins.toString (inputs.self.dirtyShortRev or "empty")}"
            '';
          };
        };
      };

      # includes unstable packages as pkgs.unstable in the pkgs argument to modules
      flake.overlays.unstable = (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config = prev.config;
        };
      });

      flake.nixosConfigurations =
        {
          wuwei = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } ./machines/wuwei;
        };

    }
  );
}

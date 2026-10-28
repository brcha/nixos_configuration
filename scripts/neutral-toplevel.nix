# Derivation path of a host's system with the per-commit inputs forced to
# constants, so that two commits that build the same system print the same
# path. Used by `just neutral`.
# shortcut: assumes the host uses sops and home-manager, guard the overrides when a host without them exists
flake: host:

let
  # Any file whose store path does not change between commits of this repository
  constantFile = "${flake.inputs.nixpkgs}/README.md";
  system = flake.nixosConfigurations.${host}.extendModules {
    modules = [
      ({ flake, lib, ... }: {
        # Both contain the git revision
        system.configurationRevision = lib.mkForce "neutral";
        system.nixos.tags = lib.mkForce [ "neutral" ];
        # Both point into the flake source, which changes with every commit
        sops.defaultSopsFile = lib.mkForce constantFile;
        home-manager.users.${flake.config.people.me}.sops.defaultSopsFile = lib.mkForce constantFile;
      })
    ];
  };
in
system.config.system.build.toplevel.drvPath

# Evaluation-only checks for the home bundles of platforms this repository does
# not build here (Darwin) or does not deploy yet (WSL). Each check is a trivial
# derivation whose text forces the bundle's activation package to evaluate.
{ self, inputs, pkgs, lib, me }:

let
  homeFor = system: bundle:
    let
      platformPkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.unstable ];
        config.allowUnfree = true;
      };
    in
    self.nixos-unified.lib.mkHomeConfiguration platformPkgs {
      imports = [ self.homeModules.${bundle} ];
      home.username = me;
      # Everything a user of that platform would turn on
      my = {
        dev.enable = true;
        apps.enable = true;
      };
    };

  evaluates = name: home: pkgs.writeText "${name}-evaluates"
    (builtins.unsafeDiscardStringContext home.activationPackage.drvPath);
in
{
  darwin = evaluates "darwin" (homeFor "aarch64-darwin" "common-darwin");
  wsl = evaluates "wsl" (homeFor "x86_64-linux" "common-wsl");
}

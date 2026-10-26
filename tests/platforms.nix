# Home configurations for platforms this repository has no host for yet: Darwin
# and WSL, as standalone home-manager setups of the user's bundles.
{ self, inputs, me }:

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
      # Mirrors wuwei's choices until each platform's bundle sets its own
      my = {
        dev.enable = true;
        apps = {
          enable = true;
          jetbrains = false;
          vscode = false;
        };
      };
    };
in
{
  darwin = homeFor "aarch64-darwin" "common-darwin";
  wsl = homeFor "x86_64-linux" "common-wsl";
}

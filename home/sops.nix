{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = self + /secrets/system.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = false;
    };
    secrets = {
      codestats-key = { };
      codestats-key-neovim = { };
      git-town-token = { };
    };
  };
}

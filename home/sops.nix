{ flake, pkgs, lib, ... }:
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
      keyFile = "/home/brcha/.config/sops/age/keys.txt";
      generateKey = false;
    };
    secrets = {
      codestats-key = { };
      codestats-key-neovim = { };
      git-town-token = { };
    };
  };
}

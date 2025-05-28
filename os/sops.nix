{ flake, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.sops-nix.nixosModules.default
  ];

  sops = {
    defaultSopsFile = self + /secrets/system.yaml;
    age = {
      keyFile = "/nix/secret/keys.txt";
      generateKey = false;
    };
    secrets = {
      brcha-password = { };
    };
  };
}

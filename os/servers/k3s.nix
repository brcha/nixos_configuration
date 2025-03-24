{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # Enable K3s
  services.k3s = {
    enable = true;
  };
}

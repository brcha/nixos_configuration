{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # Enable ClamAV updater
  services.clamav = {
    updater = {
      enable = true;
    };
    daemon = {
      enable = true;
    };
    fangfrisch = {
      enable = true;
    };
  };
}

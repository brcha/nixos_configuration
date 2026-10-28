{ flake, config, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  options.my.servers.clamav.enable = lib.mkEnableOption "ClamAV";

  config = lib.mkIf config.my.servers.clamav.enable {
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
  };
}

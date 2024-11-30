{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # Enable Tailscale
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--operator=${flake.config.people.me}"
      "--exit-node-allow-lan-access"
    ];
  };

  # Enable MagicDNS
  networking = {
    nameservers = [ "100.100.100.100" ];
    search = [ "polecat-grue.ts.net" ];
  };
}

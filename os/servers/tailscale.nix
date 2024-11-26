{ flake, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # Enable Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-key.path;
    extraUpFlags = [
      "--ssh"
      "--operator=${flake.config.people.me}"
    ];
  };

  # Enable MagicDNS
  networking = {
    nameservers = [ "100.100.100.100" ];
    search = [ "polecat-grue.ts.net" ];
  };
}

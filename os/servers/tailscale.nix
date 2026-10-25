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
    package = pkgs.unstable.tailscale;
    # Opens the WireGuard port (41641/udp) so devices on the same network connect
    # directly and not through Tailscale's relay servers
    openFirewall = true;
  };

  # The tailnet is trusted: everything arriving on tailscale0 is accepted (the zone
  # rejected it all before, SSH included). Tailscale's own access rules still apply.
  services.firewalld.zones.internal = {
    interfaces = [ "tailscale0" ];
    target = "ACCEPT";
  };

  # Enable MagicDNS
  networking = {
    nameservers = [ "100.100.100.100" ];
    search = [ "polecat-grue.ts.net" ];
  };
}

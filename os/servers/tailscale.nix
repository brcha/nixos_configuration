{ flake, config, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  options.my.servers.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.my.servers.tailscale.enable {
    # Enable Tailscale
    services.tailscale = {
      enable = true;
      # Applied with `tailscale set` on every start (extraUpFlags needs authKeyFile)
      extraSetFlags = [
        "--operator=${flake.config.people.me}"
        "--exit-node-allow-lan-access"
        # Keep local DNS: the tailnet's global nameserver would otherwise route every
        # name (~.) to MagicDNS
        "--accept-dns=false"
      ];
      package = pkgs.unstable.tailscale;
      # Opens the WireGuard port (41641/udp) so devices on the same network connect
      # directly and not through Tailscale's relay servers
      openFirewall = true;
    };

    # The tailnet is trusted: everything arriving on tailscale0 is accepted.
    # Tailscale's own access rules still apply.
    services.firewalld.zones.internal.interfaces = [ "tailscale0" ];

    # Only tailnet names go to MagicDNS. A delegate, not a tailscale0 link setting,
    # because tailscaled resets the DNS of its own link. Without "~" the domain is
    # also the search domain for short host names.
    services.resolved.dnsDelegates.tailnet.Delegate = {
      DNS = "100.100.100.100";
      Domains = "polecat-grue.ts.net";
    };
  };
}

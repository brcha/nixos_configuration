{ pkgs, libs, flake, config, ... }:

{
  # Smart DNS
  services.smartdns = {
    enable = true;
    settings = {
      server-tls = [
        # Google
        "8.8.8.8"
        "8.8.4.4"
        # 1.1.1.1
        "1.1.1.1"
        "1.0.0.1"
        # Comodo
        "8.26.56.26"
        "8.20.247.20"
        # OpenDNS
        "208.67.222.222"
        "208.67.220.220"
        # Quad9
        "9.9.9.9"
        # Yandex
        "77.88.8.88"
        "77.88.8.2"
      ];
      speed-check-mode = "ping,tcp:443";
      cache-size = 8192;
      prefetch-domain = true;
      serve-expired = true;
      bind = "127.0.0.1:53";
    };
  };

  # Use Smart DNS
  networking.nameservers = [ "127.0.0.1" ];
  # Prefer it for every name, so the DHCP servers NetworkManager adds to a link are
  # not queried. Longer routing domains (a DNS delegate, a VPN) still win.
  services.resolved.settings.Resolve.Domains = [ "~." ];
}

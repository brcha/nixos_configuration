{ pkgs, libs, flake, config, ... }:

{
  # Avahi mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      domain = true;
    };
  };

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

}

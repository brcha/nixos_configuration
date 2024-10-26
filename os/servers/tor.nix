{ pkgs, lib, config, ... }:

{
  # Enable TOR
  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = true;
    };
  };

  # Enable Privoxy
  services.privoxy = {
    enable = true;
    enableTor = true;
  };
}

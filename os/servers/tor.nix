{ pkgs, lib, config, ... }:

{
  options.my.servers.tor.enable = lib.mkEnableOption "Tor and Privoxy";

  config = lib.mkIf config.my.servers.tor.enable {
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
  };
}

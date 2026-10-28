{ pkgs, lib, config, ... }:

{
  options.my.servers.avahi.enable = lib.mkEnableOption "Avahi mDNS publishing";

  config = lib.mkIf config.my.servers.avahi.enable {
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
  };
}

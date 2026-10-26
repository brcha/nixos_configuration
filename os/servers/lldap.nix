{ flake, config, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  options.my.servers.lldap.enable = lib.mkEnableOption "LLDAP";

  config = lib.mkIf config.my.servers.lldap.enable {
    # Enable LLDAP
    services.lldap = {
      enable = true;
      settings = {
        ldap_base_dn = "dc=brcha,dc=com";
        ldap_user_email = "admin@brcha.com";
        ldap_user_pass = "adminadmin";
      };
    };

    # Setup Web UI
    services.nginx = {
      enable = true;
      virtualHosts = {
        "lldap.home" = {
          locations."/" = { proxyPass = "http://localhost:17170"; };
        };
      };
    };

    networking.hosts = {
      "127.0.0.1" = [ "lldap.home" ];
    };
  };
}

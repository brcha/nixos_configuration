{ config, pkgs, lib, ... }:

{
  options.my.servers.salmonquail.enable = lib.mkEnableOption "the SalmonQuail development virtual hosts";

  config = lib.mkIf config.my.servers.salmonquail.enable {
    # SalmonQuail ports
    networking.firewall.allowedTCPPorts = [ 4321 7654 ];

    # Enable virtual hosts for salmonquail
    services.nginx = {
      enable = true;
      virtualHosts = {
        "api.salmonquail.home" = {
          locations."/" = { proxyPass = "http://localhost:7654"; };
        };
        "app.salmonquail.home" = {
          locations."/" = { proxyPass = "http://localhost:4321"; };
        };
      };
    };

    # Make sure virtual hosts are resolved
    networking.hosts = {
      "127.0.0.1" =
        [ "api.salmonquail.home" "app.salmonquail.home" ];
    };
  };
}

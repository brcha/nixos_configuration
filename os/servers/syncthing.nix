{ flake, config, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  options.my.servers.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = lib.mkIf config.my.servers.syncthing.enable {
    # Enable Syncthing
    services.syncthing = {
      enable = true;
      user = flake.config.people.me;
      group = "users";
      configDir = "/home/${flake.config.people.me}/.config/syncthing";
      dataDir = "/home/${flake.config.people.me}";
    };

    # Syncthing ports
    networking.firewall.allowedTCPPorts = [ 8384 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    # Enable virtual host for syncthing
    services.nginx = {
      enable = true;
      virtualHosts = {
        "syncthing.home" = {
          locations."/" = { proxyPass = "http://localhost:8384"; };
        };
      };
    };

    # Make sure virtual hosts are resolved
    networking.hosts = {
      "127.0.0.1" = [ "syncthing.home" ];
    };

    environment.systemPackages = with pkgs; [
      syncthingtray
    ];
  };
}

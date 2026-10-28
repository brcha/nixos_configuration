# Torrent software

{ flake, config, pkgs, lib, ... }:

let
  me = flake.config.people.me;
  configHome = "${config.users.users.${me}.home}/.config";
in
{
  config = lib.mkIf config.my.gui.torrents {
    # Sonarr still needs these .NET 6 packages
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

    environment.systemPackages = with pkgs; [
      qbittorrent-enhanced

      popcorntime
    ];

    # Setup Sonarr
    services.sonarr = {
      enable = true;
      user = me;
      group = "users";
      dataDir = "${configHome}/Sonarr";
    };

    # Setup Radarr
    services.radarr = {
      enable = false; # doesn't work at the moment
      user = me;
      group = "users";
      dataDir = "${configHome}/Radarr";
    };

    # Setup Bazarr
    # services.bazarr.enable = true;

    # Setup Jackett
    services.jackett = {
      enable = true;
      user = me;
      group = "users";
      dataDir = "${configHome}/Jackett";
    };

    # Setup FlareSolverr
    services.flaresolverr = {
      enable = true;
    };

    # Enable virtual hosts for sonarr and company
    services.nginx = {
      enable = true;
      virtualHosts = {
        "sonarr.home" = {
          locations."/" = { proxyPass = "http://localhost:8989"; };
        };
        "radarr.home" = {
          locations."/" = { proxyPass = "http://localhost:7878"; };
        };
        #      "bazarr.home" = {
        #        locations."/" = { proxyPass = "http://localhost:6767/"; };
        #      };
        "jackett.home" = {
          locations."/" = { proxyPass = "http://localhost:9117"; };
        };
      };
    };

    # Make sure virtual hosts are resolved
    networking.hosts = {
      "127.0.0.1" =
        [ "sonarr.home" "radarr.home" "jackett.home" ];
    };
  };
}

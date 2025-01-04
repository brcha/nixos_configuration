# Torrent software

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.qbittorrent

    popcorntime
  ];

  # Setup Sonarr
  services.sonarr = {
    enable = true;
    user = "brcha";
    group = "users";
    dataDir = "/home/brcha/.config/Sonarr";
  };

  # Setup Radarr
  services.radarr = {
    enable = true;
    user = "brcha";
    group = "users";
    dataDir = "/home/brcha/.config/Radarr";
  };

  # Setup Bazarr
  # services.bazarr.enable = true;

  # Setup Jackett
  services.jackett = {
    enable = true;
    user = "brcha";
    group = "users";
    dataDir = "/home/brcha/.config/Jackett";
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
}

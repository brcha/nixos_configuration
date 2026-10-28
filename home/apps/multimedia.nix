{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.multimedia {
    home.packages = available (with pkgs; [
      # Video players
      mpv
      smplayer
      vlc

      # Video tools
      avidemux
      kdePackages.kdenlive
      mkvtoolnix

      # Audio
      lmms
      spotify

      # Streaming
      obs-studio

      # Audio routing
      qpwgraph
    ]);
  };
}

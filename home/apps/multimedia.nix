{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.multimedia {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # Video players
      mpv
      smplayer
      vlc

      # Video tools
      avidemux
      kdePackages.kdenlive
      mkvtoolnix
      yt-dlp

      # Audio/video processing
      ffmpeg-full
      frei0r

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

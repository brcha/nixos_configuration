{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
  ];
}

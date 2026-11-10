{ pkgs, available, ... }:

{
  home.packages = available (with pkgs; [
    # Video download and processing
    yt-dlp
    ffmpeg-full

    # Matroska tools
    mkvtoolnix-cli

    # Images and rendering
    imagemagick
    povray
  ]);
}

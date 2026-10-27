{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
    # Video download and processing
    yt-dlp
    ffmpeg-full
    frei0r

    # Images and rendering
    imagemagick
    povray
  ]);
}

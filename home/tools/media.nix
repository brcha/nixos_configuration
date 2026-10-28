{ pkgs, lib, config, available, ... }:

{
  home.packages = available
    (with pkgs; [
      # Video download and processing
      yt-dlp
      ffmpeg-full
      frei0r

      # Images and rendering
      imagemagick
      povray
    ])
  # Matroska tools without the GUI, where the multimedia apps (which bring the full
  # mkvtoolnix) are off
  ++ lib.optional (!config.my.apps.multimedia) pkgs.mkvtoolnix-cli;
}

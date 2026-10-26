{ pkgs, lib, ... }:

{
  # Packages not built for this platform are left out
  home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
    # Video download and processing
    yt-dlp
    ffmpeg-full
    frei0r

    # Images and rendering
    imagemagick
    povray
  ]);
}

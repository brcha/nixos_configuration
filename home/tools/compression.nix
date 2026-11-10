{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Archive tools
    lrzip
    p7zip
    unrar
    unzip
    xar
    zip
    zpaq

    # Compression algorithms
    brotli
    lz4
    lzip
    squashfsTools
    zstd

    # Delta downloads
    zsync
  ];
}

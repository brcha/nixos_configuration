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
    lzop
    rzip
    squashfsTools
    upx
    zstd

    # Delta and sync
    xdelta
    zsync
  ];
}

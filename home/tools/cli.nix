{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Modern CLI replacements
    bat
    fd
    gdu
    jq
    yq-go

    # System monitoring
    fastfetch
    htop

    # Shell helpers
    just
    lesspipe

    # File management
    lsof
    mc
    tree

    # Data processing
    csvtool

    # HTTP client
    httpie

    # Coreutils replacement
    uutils-coreutils-noprefix
  ];
}

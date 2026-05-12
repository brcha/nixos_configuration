{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Modern CLI replacements
    bat
    fd
    fzf
    gdu
    jq
    yq-go

    # System monitoring
    fastfetch
    htop
    neofetch

    # Shell helpers
    cheat
    just
    lesspipe

    # File management
    lsof
    mc
    tree

    # Data processing
    csvtool
    skim

    # HTTP client
    httpie

    # Coreutils replacement
    uutils-coreutils-noprefix

    # Version manager
    unstable.asdf-vm
  ];
}

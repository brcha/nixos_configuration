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

  programs.fastfetch = {
    enable = true;
    # The Zpool module needs libzfs, which the default build leaves out
    package = pkgs.fastfetch.override { zfsSupport = pkgs.stdenv.isLinux; };
    # fastfetch's default modules, with ZFS shown per pool instead of per mount.
    # Without ZFS the Zpool module prints nothing and Disk works as usual;
    # tmpfs is hidden for an impermanent root.
    settings.modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "display"
      "de"
      "wm"
      "wmtheme"
      "theme"
      "icons"
      "font"
      "cursor"
      "terminal"
      "terminalfont"
      "cpu"
      "gpu"
      "memory"
      "swap"
      { type = "disk"; hideFS = "zfs:tmpfs"; }
      "zpool"
      "localip"
      "battery"
      "poweradapter"
      "locale"
      "break"
      "colors"
    ];
  };
}

{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
    # System information
    file
    lsb-release
    psmisc

    # Geolocation
    geoipWithDatabase

    # System monitoring
    sysstat

    # File list partitioning
    fpart

    # Password utilities
    mkpasswd
    pwgen

    # Extended attributes
    python3Packages.xattr

    # Nix utilities
    unstable.cachix
  ]);

  # `, <command>` runs a program from nixpkgs without installing it; the prebuilt
  # nix-index database also gives the shell a command-not-found handler
  programs.nix-index-database.comma.enable = true;
}

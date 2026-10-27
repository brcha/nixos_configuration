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
    pxattr
    python312Packages.xattr

    # Nix utilities
    nox
    unstable.cachix
  ]);
}

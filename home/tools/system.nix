{ pkgs, lib, ... }:

{
  # Packages not built for this platform are left out; hardware and disk tools are in hardware.nix
  home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
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

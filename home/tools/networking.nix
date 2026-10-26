{ pkgs, lib, ... }:

{
  # Packages not built for this platform are left out; CAN bus and boot media tools are in hardware.nix
  home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
    # Network scanners
    nmap
    rustscan

    # VPN
    wireguard-tools

    # Download managers
    aria2

    # Network utilities
    dig
    inetutils
    socat
    wget

    # Tunnelling
    ngrok
  ]);
}

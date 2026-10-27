{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
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

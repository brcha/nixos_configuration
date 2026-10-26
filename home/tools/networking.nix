{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

    # CAN bus tools
    can-utils
    cantoolz

    # Tunnelling
    ngrok
    unstable.bootiso
  ];
}

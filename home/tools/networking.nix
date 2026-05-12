{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Network scanners
    nmap
    rustscan

    # VPN
    protonmail-bridge-gui
    protonvpn-gui
    strongswanNM
    wireguard-tools

    # Download managers
    aria2
    persepolis

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

    # Tailscale GUI
    ktailctl
  ];
}

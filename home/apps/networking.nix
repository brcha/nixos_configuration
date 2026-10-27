{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.networking {
    home.packages = available
      (with pkgs; [
        # VPN
        protonmail-bridge-gui
        proton-vpn

        # Download manager
        persepolis
      ])
    # Linux-only, though their metadata does not show it: NetworkManager's strongSwan
    # plugin, and the KDE-based Tailscale GUI
    ++ lib.optionals pkgs.stdenv.isLinux [
      pkgs.strongswanNM
      pkgs.ktailctl
    ];
  };
}

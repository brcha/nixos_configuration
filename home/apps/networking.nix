{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.networking {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # VPN
      protonmail-bridge-gui
      proton-vpn
      strongswanNM

      # Download manager
      persepolis

      # Tailscale GUI
      ktailctl
    ]);
  };
}

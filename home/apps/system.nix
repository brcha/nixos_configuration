{ pkgs, lib, config, ... }:

{
  # X11, Mesa and Razer tools and Vorta are Linux desktop tools
  config = lib.mkIf (config.my.apps.system && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      # Xorg utilities
      xdpyinfo
      xev
      xhost
      xwininfo

      # Graphics info
      mesa-demos
      vulkan-tools
      wayland-utils

      # Backup GUI
      vorta

      # Peripheral management
      openrazer-daemon
      razergenie
    ];
  };
}

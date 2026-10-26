{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.system {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
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
    ]);
  };
}

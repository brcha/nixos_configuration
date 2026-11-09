{ pkgs, lib, config, ... }:

{
  # Mesa, Wayland and Razer tools are Linux desktop tools
  config = lib.mkIf (config.my.apps.system && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      # Graphics info
      mesa-demos
      vulkan-tools
      wayland-utils

      # Peripheral management
      razergenie
    ];
  };
}

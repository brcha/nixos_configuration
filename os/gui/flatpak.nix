{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.gui.flatpak {
    # Enable flatpak here, not in userspace

    # Enable Flatpak
    services.flatpak.enable = true;

    # XDG Settings
    xdg = {
      # Enable XDG Portals
      portal = {
        enable = true;
        xdgOpenUsePortal = true; # use portals from fhs envs
      };
    };
  };
}

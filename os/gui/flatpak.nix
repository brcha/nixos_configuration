{ pkgs, lib, config, ... }:

{
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
}

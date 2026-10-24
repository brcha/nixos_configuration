{ flake, pkgs, config, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Hyprland's own portal for screen sharing and global shortcuts, KDE's for
  # file dialogs and the colour scheme, GTK as the fallback
  xdg.portal.config.hyprland.default = [ "hyprland" "kde" "gtk" ];

  # QML module used by KDE settings pages (kcm_networkmanagement); Plasma's own
  # session wrapper provides it, other sessions do not
  environment.systemPackages = [ pkgs.kdePackages.ksvg ];

  # PAM service for the lock screen. programs.hyprlock.enable is avoided on
  # purpose: it also enables a hypridle user unit wanted by
  # graphical-session.target, which would run in the Plasma session too.
  security.pam.services.hyprlock = { };
}

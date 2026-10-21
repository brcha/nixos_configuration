{ flake, pkgs, config, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # PAM service for the lock screen. programs.hyprlock.enable is avoided on
  # purpose: it also enables a hypridle user unit wanted by
  # graphical-session.target, which would run in the Plasma session too.
  security.pam.services.hyprlock = { };
}

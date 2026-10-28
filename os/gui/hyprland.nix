{ flake, pkgs, config, lib, ... }:

{
  config = lib.mkIf config.my.hyprland.enable {
    assertions = [{
      assertion = config.my.gui.enable;
      message = "my.hyprland.enable requires my.gui.enable";
    }];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # Login screen preselects Hyprland (the UWSM-managed entry); Plasma stays in the
    # session list. The SDDM state is lost with the root rollback, so it would
    # otherwise fall back to the default on every boot.
    services.displayManager.defaultSession = "hyprland-uwsm";

    # Hyprland's own portal for screen sharing and global shortcuts, KDE's for
    # file dialogs and the colour scheme, GTK as the fallback; KWallet's for
    # secrets (its portal file is kwallet.portal, and kde.portal lacks Secret)
    xdg.portal.config.hyprland = {
      default = [ "hyprland" "kde" "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
    };

    # QML module used by KDE settings pages (kcm_networkmanagement); Plasma's own
    # session wrapper provides it, other sessions do not
    environment.systemPackages = [ pkgs.kdePackages.ksvg ];

    # PAM service for the lock screen. programs.hyprlock.enable is avoided on
    # purpose: it also enables a hypridle user unit wanted by
    # graphical-session.target, which would run in the Plasma session too.
    security.pam.services.hyprlock = { };
  };
}

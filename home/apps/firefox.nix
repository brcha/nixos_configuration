{ pkgs, misc, lib, inputs, config, ... }:

{
  config = lib.mkIf config.my.apps.firefox {
    programs = {
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        package = pkgs.firefox.override {
          # KDE's browser integration exists on Linux only, and is only useful
          # in the Plasma and Hyprland sessions, which both run KDE services
          nativeMessagingHosts = lib.optionals (pkgs.stdenv.isLinux && (config.my.kde.enable || config.my.hyprland.enable)) [
            pkgs.kdePackages.plasma-browser-integration
          ];
        };
      };

      browserpass = {
        enable = true;
        browsers = [
          "firefox"
          "chrome"
        ];
      };
    };

    home.packages = [
      pkgs.google-chrome
    ]
    # The Zen flake builds for Linux only
    ++ lib.optional pkgs.stdenv.isLinux pkgs.zen-browser;
  };
}

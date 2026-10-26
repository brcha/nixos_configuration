{ pkgs, misc, lib, inputs, config, ... }:

{
  config = lib.mkIf config.my.apps.firefox {
    programs = {
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        package = pkgs.firefox.override {
          # KDE's browser integration exists on Linux only
          nativeMessagingHosts = lib.optionals pkgs.stdenv.isLinux [
            pkgs.kdePackages.plasma-browser-integration
          ];
        };
      };

      browserpass = {
        enable = true;
        browsers = [
          "firefox"
          "brave"
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

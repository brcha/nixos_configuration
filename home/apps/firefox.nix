{ pkgs, misc, lib, inputs, config, ... }:

{
  programs = {
    firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";

      package = pkgs.firefox.override {
        nativeMessagingHosts = with pkgs; [
          kdePackages.plasma-browser-integration
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

  home.packages = with pkgs; [
    google-chrome
    zen-browser
  ];
}

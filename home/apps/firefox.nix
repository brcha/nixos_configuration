{ pkgs, misc, lib, inputs, ... }:

{
  programs = {
    firefox = {
      enable = true;

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

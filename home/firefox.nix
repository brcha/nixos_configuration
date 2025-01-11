{ pkgs, misc, lib, ... }:

{
  programs = {
    firefox = {
      enable = true;

      package = pkgs.firefox.override {
        nativeMessagingHosts = with pkgs; [
          plasma-browser-integration
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
    librewolf
  ];
}

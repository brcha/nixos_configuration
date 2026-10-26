{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.communication {
    home.packages = with pkgs; [
      # Messaging
      discord
      telegram-desktop

      # Video conferencing
      unstable.zoom-us
      webex
    ];
  };
}

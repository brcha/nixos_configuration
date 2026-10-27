{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.communication {
    home.packages = available (with pkgs; [
      # Messaging
      discord
      telegram-desktop

      # Video conferencing
      unstable.zoom-us
      webex
    ]);
  };
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Messaging
    discord
    telegram-desktop

    # Video conferencing
    unstable.zoom-us
  ];
}

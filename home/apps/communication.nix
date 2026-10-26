{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.communication {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # Messaging
      discord
      telegram-desktop

      # Video conferencing
      unstable.zoom-us
      webex
    ]);
  };
}

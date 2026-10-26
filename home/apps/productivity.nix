{ pkgs, lib, config, ... }:

let
  # Packages not built for this platform (Linux-only apps on the Mac) are left out
  available = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform);
in
{
  config = lib.mkIf config.my.apps.productivity {
    home.packages = available
      (with pkgs; [
        # Documentation browser
        zeal

        # Notes
        joplin-desktop

        # Time tracking
        clockify

        # Office suite
        libreoffice-qt
      ])
    # Todo.txt manager GUI, only where its flake supports it (the CLI is in home/tools)
    ++ available [ pkgs.rtm.rtmapp ];
  };
}

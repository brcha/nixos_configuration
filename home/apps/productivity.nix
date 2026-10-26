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
        wakatime-cli

        # Finance
        hledger
        hledger-interest
        hledger-ui
        hledger-web

        # Office suite
        libreoffice-qt

        # Document conversion
        html2text
      ])
    # Todo.txt manager: the CLI builds everywhere, the GUI only where its flake supports it
    ++ [ pkgs.rtm.rtmcli ]
    ++ available [ pkgs.rtm.rtmapp ];
  };
}

{ pkgs, lib, ... }:

{
  # Packages not built for this platform are left out
  home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
    # Time tracking
    wakatime-cli

    # Finance
    hledger
    hledger-interest
    hledger-ui
    hledger-web

    # Document conversion
    html2text

    # Todo.txt manager
    rtm.rtmcli
  ]);
}

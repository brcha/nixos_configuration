{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
    # Time tracking
    wakatime-cli

    # Finance
    hledger
    hledger-interest
    hledger-ui
    hledger-web

    # Document conversion
    html2text
    pandoc

    # Todo.txt manager
    rtm.rtmcli
  ]);
}

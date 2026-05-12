{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
  ];
}

{ pkgs, misc, lib, ... }:

{
  home.packages = with pkgs; [
    # Basic utilities
    kdePackages.ark
    kdePackages.okular
    kdePackages.gwenview
    flameshot # better screenshotting tool than spectacle
    kdePackages.yakuake
    kdePackages.kate

    # Extra kde frameworks libs
    kdePackages.kio-gdrive
    kdePackages.kio-extras
    kdePackages.kaccounts-providers
    kdePackages.signond
    kdePackages.kde-gtk-config

    # KDE PIM
    kdePackages.kmail
    kdePackages.korganizer
    kdePackages.kontact
    kdePackages.kaddressbook
    kdePackages.akonadi
    kdePackages.akonadi-mime
    kdePackages.akonadi-contacts
    kdePackages.akonadi-calendar
    kdePackages.akonadiconsole
    kdePackages.kmail-account-wizard
    kdePackages.kmailtransport
    kdePackages.kleopatra # Cert manager
    kdePackages.kgpg

    # Non KDE, but KDE-related packages
    kdePackages.plasma-nm

    # Kvantum style (and, for fun, other styles)
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugins

    # Remobe desktop
    kdePackages.krdc
    kdePackages.krfb
  ];
}

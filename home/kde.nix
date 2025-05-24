{ pkgs, misc, lib, ... }:

{
  home.packages = with pkgs; [
    # Basic utilities
    kdePackages.ark
    okular
    gwenview
    flameshot # better screenshotting tool than spectacle
    yakuake
    kate
    kdePackages.kteatime
    krusader

    # Extra kde frameworks libs
    kdePackages.kio-gdrive
    kdePackages.kio-extras
    kdePackages.kaccounts-providers
    kdePackages.signond
    kdePackages.kde-gtk-config

    # KDE PIM
    kmail
    korganizer
    kontact
    kaddressbook
    akonadi
    kdePackages.akonadi-mime
    kdePackages.akonadi-contacts
    kdePackages.akonadi-calendar
    kdePackages.akonadiconsole
    kdePackages.kmail-account-wizard
    kdePackages.kmailtransport
    kleopatra # Cert manager
    kgpg

    # Non KDE, but KDE-related packages
    latte-dock
    plasma-nm
    krunner-pass

    # Kvantum style (and, for fun, other styles)
    qt6Packages.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qtstyleplugins

    # Remobe desktop
    kdePackages.krdc
    kdePackages.krfb
  ];
}

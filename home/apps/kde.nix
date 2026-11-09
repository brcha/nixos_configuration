{ pkgs, misc, lib, config, ... }:

let
  # An IMAP login to the local Proton Bridge before it has loaded its users fails,
  # and the resource does not retry; hold Akonadi back until Bridge is ready
  bridge-wait = pkgs.writeShellApplication {
    name = "akonadi-bridge-wait";
    runtimeInputs = with pkgs; [ coreutils systemd ];
    text = ''
      # shortcut: Bridge has no readiness signal and loads its users about 5 s after
      # it starts; replace the wait if Bridge or the IMAP resource gains one
      started=$(systemctl --user show --timestamp=unix -P ActiveEnterTimestamp app-ProtonMailBridge@autostart.service)
      [ -n "$started" ] || exit 0
      left=$((''${started#@} + 15 - $(date +%s)))
      if [ "$left" -gt 0 ]; then
        sleep "$left"
      fi
    '';
  };
in
{
  config = lib.mkIf config.my.kde.enable {
    home.packages = with pkgs; [
      # Basic utilities; ark, okular, gwenview, kate, kio-extras, kde-gtk-config,
      # akonadi and plasma-nm come with the NixOS Plasma 6 module
      flameshot # better screenshotting tool than spectacle
      kdePackages.yakuake

      # Extra kde frameworks libs
      kdePackages.kio-gdrive
      kdePackages.kaccounts-providers
      kdePackages.signond

      # KDE PIM; the Akonadi libraries ship the serializer plugins and the reminder
      # daemon that the Akonadi server finds through the profile
      kdePackages.kmail
      kdePackages.korganizer
      kdePackages.kontact
      kdePackages.kaddressbook
      kdePackages.akonadi-mime
      kdePackages.akonadi-contacts
      kdePackages.akonadi-calendar
      kdePackages.kmail-account-wizard
      kdePackages.kmailtransport
      kdePackages.kleopatra # Cert manager
      kdePackages.kgpg

      # Kvantum style
      kdePackages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum

      # Remote desktop
      kdePackages.krdc
      kdePackages.krfb

      kdotool
    ];

    # Akonadi stores the MariaDB server's store path on every start and keeps
    # using it after a MariaDB update, so the server no longer matches its tools
    xdg.configFile."systemd/user/akonadi_control.service.d/server-path.conf".text = ''
      [Service]
      ExecStartPre=-${pkgs.gnused}/bin/sed -i /^ServerPath=/d %h/.config/akonadi/akonadiserverrc
    '';

    # Bridge starts from XDG autostart, in Plasma and Hyprland alike; only an Akonadi
    # start within 15 s of Bridge's waits
    xdg.configFile."systemd/user/akonadi_control.service.d/bridge-wait.conf" = lib.mkIf config.my.apps.networking {
      text = ''
        [Unit]
        After=app-ProtonMailBridge@autostart.service

        [Service]
        ExecStartPre=-${lib.getExe bridge-wait}
        TimeoutStartSec=30
      '';
    };
  };
}

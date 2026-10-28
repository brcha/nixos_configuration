{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.cloud-storage {
    home.packages = available (with pkgs; [
      # Cloud sync clients; the CLI daemons belong here too, since they only make
      # sense on a desktop (not on WSL)
      dropbox
      megasync
      onedrive
      onedrivegui
      yandex-disk
    ]);

    # Keeps ~/Yandex.Drive in sync; yandex-disk is Linux only
    systemd.user.services.yandex-disk = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "Yandex-disk service";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = "${pkgs.yandex-disk}/bin/yandex-disk start --no-daemon --config=%h/.config/yandex-disk/config.cfg --dir=%h/Yandex.Drive";
        ExecStop = "${pkgs.yandex-disk}/bin/yandex-disk stop";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}

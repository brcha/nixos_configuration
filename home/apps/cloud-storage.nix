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
  };
}

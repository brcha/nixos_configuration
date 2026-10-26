{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.cloud-storage {
    home.packages = with pkgs; [
      # Cloud sync clients
      dropbox
      megasync
      onedrive
      onedrivegui
      yandex-disk
    ];
  };
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Cloud sync clients
    dropbox
    megasync
    onedrive
    onedrivegui
    yandex-disk
  ];
}

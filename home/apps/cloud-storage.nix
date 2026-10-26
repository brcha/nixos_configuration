{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.cloud-storage {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # Cloud sync clients
      dropbox
      megasync
      onedrive
      onedrivegui
      yandex-disk
    ]);
  };
}

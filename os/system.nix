{ lib, config, ... }:

{
  # Defaults for every machine; a machine can set its own values

  # Keep the journal of earlier boots, within bounds, and write it out often
  # enough to keep the last messages before a hang
  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=4G
    MaxRetentionSec=3month
    SyncIntervalSec=30s
  '';

  # Compressed swap in RAM
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = lib.mkDefault "zstd";
    memoryPercent = lib.mkDefault 25;
  };

  # ZFS maintenance on machines that use ZFS
  services.zfs = lib.mkIf config.boot.zfs.enabled {
    autoScrub.enable = lib.mkDefault true;
    trim.enable = lib.mkDefault true;
  };
}

{ pkgs, lib, config, ... }:

{
  # Tools for real hardware and disks on Linux; WSL turns them off, and several
  # (ZFS helpers, appimage-run, bootiso) need Linux-only dependencies that their
  # own metadata does not show, so the whole module is Linux-only
  config = lib.mkIf (config.my.tools.hardware && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      # Hardware information
      cpufrequtils
      hwinfo
      lm_sensors
      lshw
      pciutils
      usbutils

      # Hardware monitoring
      hddtemp
      msr-tools
      smartmontools

      # Graphics info
      clinfo

      # File systems
      dosfstools
      exfat
      ntfs3g

      # Storage management
      btrfs-progs
      gptfdisk
      parted

      # ZFS and its snapshot tools
      sanoid
      zfs
      zfs-replicate
      znapzend

      # AppImage support
      appimage-run

      # CAN bus tools
      can-utils
      cantoolz

      # Boot media
      unstable.bootiso
    ];
  };
}

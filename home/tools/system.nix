{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hardware information
    cpufrequtils
    file
    hwinfo
    lm_sensors
    lsb-release
    lshw
    pciutils
    psmisc
    usbutils

    # Geolocation
    geoipWithDatabase

    # System monitoring
    hddtemp
    msr-tools
    smartmontools
    sysstat

    # Graphics info
    clinfo

    # Filesystems
    dosfstools
    exfat
    ntfs3g

    # ZFS and storage management
    btrfs-progs
    fpart
    gptfdisk
    parted
    sanoid
    zfs
    zfs-replicate
    znapzend

    # AppImage support
    appimage-run

    # Password utilities
    mkpasswd
    pwgen

    # Extended attributes
    pxattr
    python312Packages.xattr

    # Nix utilities
    nox
    unstable.cachix
  ];
}

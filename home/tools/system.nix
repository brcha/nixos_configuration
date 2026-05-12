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

    # Xorg utilities
    xorg.xdpyinfo
    xorg.xev
    xorg.xhost
    xorg.xwininfo

    # Graphics info
    clinfo
    mesa-demos
    vulkan-tools
    wayland-utils

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
    vorta
    zfs
    zfs-replicate
    znapzend

    # AppImage support
    appimage-run

    # Peripheral management
    openrazer-daemon
    razergenie

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

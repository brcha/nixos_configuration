{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/552A-CE5A";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "zroot/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zroot/nixos/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "zroot/persistent/persist";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zroot/persistent/home";
    fsType = "zfs";
  };

  fileSystems."/home/brcha" = {
    device = "zroot/persistent/home/brcha";
    fsType = "zfs";
  };

  fileSystems."/root/secret" = {
    device = "zroot/persistent/secret";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt" = {
    device = "zroot/persistent/libvirt";
    fsType = "zfs";
  };

  fileSystems."/var/lib/bluetooth" = {
    device = "zroot/persistent/bluetooth";
    fsType = "zfs";
  };

  fileSystems."/data" = {
    device = "ztank/data";
    fsType = "zfs";
  };

  fileSystems."/data/igre" = {
    device = "ztank/data/igre";
    fsType = "zfs";
  };

  fileSystems."/data/postgresql" = {
    device = "ztank/data/postgresql";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/Downloads" = {
    device = "ztank/brcha/Downloads";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/Dropbox" = {
    device = "ztank/brcha/Dropbox";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/Yandex.Drive" = {
    device = "ztank/brcha/Yandex.Drive";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/MEGA" = {
    device = "ztank/brcha/MEGA";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/OneDrive" = {
    device = "ztank/brcha/OneDrive";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/tmp" = {
    device = "ztank/brcha/tmp";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/Android" = {
    device = "ztank/brcha/Android";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.local/share/Steam" = {
    device = "zroot/cache/Steam";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.var/app/com.valvesoftware.Steam" = {
    device = "zroot/cache/SteamFlatpak";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.local/share/Zeal" = {
    device = "zroot/cache/Zeal";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/Apps" = {
    device = "zroot/cache/Apps";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.cache" = {
    device = "zroot/cache/dot_cache";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.ccache" = {
    device = "zroot/cache/ccache";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.cache/sccache" = {
    device = "zroot/cache/sccache";
    fsType = "zfs";
  };

  fileSystems."/home/brcha/.local/share/akonadi" = {
    device = "zroot/cache/akonadi";
    fsType = "zfs";
  };

  fileSystems."/data/VirtualBox VMs" = {
    device = "ztank/data/vbox";
    fsType = "zfs";
  };

  fileSystems."/data/VirtualBox VMs/Vogele" = {
    device = "ztank/data/vbox/vogele";
    fsType = "zfs";
  };
  
  fileSystems."/data/vmware" = {
    device = "ztank/data/vmware";
    fsType = "zfs";
  };

  fileSystems."/data/vmware/windowsserver2025" = {
    device = "ztank/data/vmware/windowsserver2025";
    fsType = "zfs";
  };

  fileSystems."/data/vmware/windowsserver2022" = {
    device = "ztank/data/vmware/windowsserver2022";
    fsType = "zfs";
  };

  fileSystems."/data/virt" = {
    device = "ztank/data/virt";
    fsType = "zfs";
  };

  swapDevices = [ ];
}

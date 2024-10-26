{ config, pkgs, lib, ... }:

{
  # Boot related stuff
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.memtest86.enable = true;

      timeout = 5;

      # No need for systemd-boot command-line editor
      systemd-boot.editor = false;
    };

    initrd.systemd = {
      # enable = true;
      services = {
        # Rollback root to blank on each boot
        rollback = {
          description = "Rollback ZFS dataset to a pristine state";
          wantedBy = [
            "initrd.target"
          ];
          after = [
            "zfs-import-zroot.service"
          ];
          before = [
            "sysroot.mount"
          ];
          path = with pkgs; [
            zfs
          ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r zroot/nixos/root@blank && echo "rollback complete"
          '';
        };
      };
    };

    vesa = true;
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };

    # kernelPackages = pkgs.linuxPackages_lqx; # Breaks ZFS at the moment
    kernelModules = [
      "acpi-cpufreq"
      "cpufreq-ondemand"
      "v4l2loopback"
      #      "8812au"
      #      "8821au"
      "can-isotp"
      "zenpower"
    ];
    extraModulePackages = with config.boot.kernelPackages;
      [
        v4l2loopback
        #        (v4l2loopback.overrideAttrs ({ ... }: {
        #          src = pkgs.fetchFromGitHub {
        #            owner = "umlaeute";
        #            repo = "v4l2loopback";
        #            rev = "10b1c7e6bda4255fdfaa187ce2b3be13433416d2";
        #            sha256 = "0xsn4yzj7lwdg0n7q3rnqpz07i9i011k2pwn06hasd45313zf8j2";
        #          };
        #        }))
        # anbox # BROKEN in 21.05
        # rtl88xxau-aircrack # BROKEN at the moment
        # rtl8821au
        # exfat-nofuse # BROKEN in 21.05
      ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
    '';

    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ ];
    };
  };
}

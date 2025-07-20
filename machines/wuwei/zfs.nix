{ pkgs, lib, config, ... }:

{
  # Extra config for empty root on every boot
  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/acme - - - - /persist/var/lib/acme"
    "L /var/lib/cups - - - - /persist/var/lib/cups"
    "L /var/lib/flatpak - - - - /persist/var/lib/flatpak"
  ];

  # ZramSwap
  zramSwap = {
    enable = true; # Enable zramSwap, default 50% of RAM
  };

  # ZFS related settings
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.znapzend = {
    enable = true;
    pure = true;
    autoCreation = true;
    features = {
      sendRaw = true;
      oracleMode = true;
    };
    zetup = {
      # Backup persistent datasets (/home, /var/lib, /root/secret)
      "zroot/persistent" = {
        # 6 hour intervals inside 1 day, …
        plan = "1d=>6h,1w=>3d,6m=>1m";
        recursive = true;
        timestampFormat = "znapzend_%Y-%m-%d-%H%M%S";
        destinations = {
          # from ssd to hdd
          ssd2hdd = {
            dataset = "ztank/backup";
            plan = "1d=>6h,1w=>3d,6m=>1m";
          };
        };
      };

      # No backup, just snapshot
      "ztank/brcha" = {
        plan = "1d=>6h,1w=>3d,6m=>1m";
        recursive = true;
        timestampFormat = "znapzend_%Y-%m-%d-%H%M%S";
      };

      # No backup, just snapshot
      "ztank/data" = {
        plan = "1d=>6h,1w=>3d,6m=>1m";
        recursive = true;
        timestampFormat = "znapzend_%Y-%m-%d-%H%M%S";
      };

      # No backup, just snapshot
      "zroot/cache" = {
        plan = "1d=>6h,1w=>3d,6m=>1m";
        recursive = true;
        timestampFormat = "znapzend_%Y-%m-%d-%H%M%S";
      };
    };
  };
}

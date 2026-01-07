{ pkgs, lib, config, ... }:

{
  networking = {
    hostName = "wuwei"; # Define your hostname.
    hostId = "ddd5d894"; # Needed for ZFS
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;
    interfaces = { enp5s0 = { useDHCP = true; }; };
    networkmanager = {
      enable = true;
      # dns = "none"; # use local dns (smartdns)
      # enable ipsec
      plugins = with pkgs; [
        networkmanager-strongswan
      ];
    };
    wireguard = { enable = true; };
    # resolvconf.enable = false;
    dhcpcd.extraConfig = "nohook resolv.conf";
    nameservers = [
      "127.0.0.1" # Smart DNS
    ];

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Setup known hosts
    hosts = {
      "46.101.144.27" = [ "apeiron" ];
      "135.181.151.18" = [ "jt" ];
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      # Setup CAN virtual devices
      "50-vcan0" = {
        enable = true;
        netdevConfig = {
          Name = "vcan0";
          Kind = "vcan";
        };
      };
    };

    networks = {
      # Setup split tunneling
      "40-enp5s0" = {
        routes = [
          # BitLy.com
          {
            Destination = "67.199.248.14";
            Gateway = "192.168.1.1";
          }
          {
            Destination = "67.199.248.15";
            Gateway = "192.168.1.1";
          }
          # FreeBitCo.in
          {
            Destination = "104.22.6.169";
            Gateway = "192.168.1.1";
          }
          {
            Destination = "104.22.7.169";
            Gateway = "192.168.1.1";
          }
          {
            Destination = "172.67.6.49";
            Gateway = "192.168.1.1";
          }
        ];
      };
    };
  };

  # This has to be here for Ipsec connections to work.
  environment.etc."ipsec.secrets".text = ''
    include ipsec.d/ipsec.nm-l2tp.secrets
  '';

  # Setup firewalld
  services.firewalld = {
    enable = true;
    zones = {
      home = {
        interfaces = [ "enp5s0" ];
        forward = true;
      };
      internal = {
        forward = true;
      };
    };
  };
}

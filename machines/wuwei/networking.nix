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
    # NetworkManager runs the real connection and networkd manages no link, so its
    # wait-online only times out (2 min) and holds up the login screen and sessions
    wait-online.enable = false;
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
  };

  # This has to be here for Ipsec connections to work.
  environment.etc."ipsec.secrets".text = ''
    include ipsec.d/ipsec.nm-l2tp.secrets
  '';
}

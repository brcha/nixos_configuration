{ flake, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  sops.secrets.brcha-password.neededForUsers = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    groups.users.gid = 100;
    users.${flake.config.people.me} = {
      uid = 1000;
      description = me.name;
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.${me.hashedPasswordFile}.path;
      extraGroups = [
        "wheel"
        "networkmanager"
        "nm-openvpn"
        "disk"
        "audio"
        "video"
        "render"
        "kvm"
        "fuse"
        "docker"
        "adbusers"
        "vboxusers"
        "plugdev"
        "libvirtd"
        "qemu-libvirtd"
        "kvm"
        "openrazer"
        "dialout"
      ];
      openssh.authorizedKeys.keys = me.sshKeys;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
}

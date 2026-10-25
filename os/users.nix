{ flake, pkgs, config, ... }:
let
  me = flake.config.people.users.${flake.config.people.me};
in
{
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
        "vboxusers"
        "plugdev"
        "openrazer"
        "dialout"
        "docker"
      ];
      openssh.authorizedKeys.keys = me.sshKeys;
    };
  };
}

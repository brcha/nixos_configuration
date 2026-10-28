{ flake, pkgs, lib, config, ... }:

let
  cfg = config.my.virtualisation;
  me = flake.config.people.me;
in
{
  options.my.virtualisation = import ../../lib/group.nix lib config "virtualisation" "virtualisation" [
    "docker"
    "vmware"
  ] // {
    virtualbox = lib.mkEnableOption "VirtualBox (off even when the group is on)";
  };

  # Each child switches its own part, so a child works with the group off
  config = {
    users.users.${me}.extraGroups =
      lib.optional cfg.docker "docker" ++ lib.optional cfg.virtualbox "vboxusers";

    virtualisation = {
      virtualbox.host = {
        enable = cfg.virtualbox;
        enableExtensionPack = true;
      };
      vmware.host = {
        enable = cfg.vmware;
      };
      docker = {
        enable = cfg.docker;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        daemon = {
          settings = {
            data-root = "/var/lib/docker";
          };
        };
      };
    };
  };
}

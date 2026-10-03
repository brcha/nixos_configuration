{ pkgs, lib, config, ... }:

{
  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    vmware.host = {
      enable = true;
    };
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      storageDriver = "zfs";
      daemon = {
        settings = {
          data-root = "/var/lib/docker";
        };
      };
    };
  };
}

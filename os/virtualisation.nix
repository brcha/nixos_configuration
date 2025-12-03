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
  };
}

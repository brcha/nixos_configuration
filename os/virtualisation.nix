{ pkgs, lib, config, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true; # Prune docker images (weekly by default)
    };
    podman = {
      enable = true;
      dockerCompat = false; # alias docker to podman
    };
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    libvirtd = { enable = true; };
    # anbox.enable = true; # BROKEN in 21.05
    spiceUSBRedirection.enable = true;
  };
}

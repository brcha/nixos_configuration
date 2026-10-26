{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    self.nixosModules.home
    self.nixosModules.linux
    ./filesystems.nix
    ./boot.nix
    ./persistence.nix
    ./hardware.nix
    ./networking.nix
  ];

  my = {
    gui.enable = true;
    kde.enable = true;
    hyprland.enable = true;
    hardware = {
      sound.enable = true;
      printing.enable = true;
      razer.enable = true;
    };
    virtualisation.enable = true;
    dev = {
      enable = true;
      jetbrains = false;
      vscode = false;
    };
    apps.enable = true;
    servers = {
      avahi.enable = true;
      clamav.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      tor.enable = true;
    };
  };

  # Docker keeps its images in ZFS datasets on this machine
  virtualisation.docker.storageDriver = "zfs";

  nixpkgs = {
    hostPlatform = "x86_64-linux";
  };

  # Build limits for this machine's CPU and memory
  nix.settings = {
    max-jobs = 16;
    cores = 2;
  };

  system = {
    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    stateVersion = "22.05";

    # Disable autoupgrade
    autoUpgrade = {
      enable = false;
      allowReboot = false;
    };
  };

}

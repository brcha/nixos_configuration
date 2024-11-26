{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    self.nixosModules.linux
    "${self}/os/nix.nix"
    ./filesystems.nix
    ./boot.nix
    ./zfs.nix
    ./hardware.nix
    ./networking.nix
    self.guiModules.default
    self.guiModules.kde
    "${self}/os/servers/postgresql.nix"
    "${self}/os/servers/redis.nix"
    "${self}/os/servers/tor.nix"
    "${self}/os/printing.nix"
    "${self}/os/virtualisation.nix"
    "${self}/os/dns.nix"
    "${self}/os/sound.nix"
    "${self}/os/gui/torrents.nix"
    "${self}/os/servers/salmonquail.nix"
    "${self}/os/servers/teamviewer.nix"
    "${self}/os/servers/syncthing.nix"
    "${self}/os/servers/ollama.nix"
    "${self}/os/servers/tailscale.nix"
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
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

# Test hosts built from the shared modules alone, without any machine
{ self }:

let
  inherit (self.nixos-unified.lib) mkLinuxSystem;

  # The least a NixOS system needs to evaluate
  stub = {
    nixpkgs.hostPlatform = "x86_64-linux";
    boot.loader.grub.devices = [ "nodev" ];
    fileSystems."/" = { device = "none"; fsType = "tmpfs"; };
    system.stateVersion = "25.11";
  };
in
rec {
  # A server: the core and every switchable module, no home-manager
  bare = mkLinuxSystem { } {
    imports = [ self.nixosModules.default self.nixosModules.linux stub ];
  };

  # A desktop-like host with the user's home-manager setup
  withHome = mkLinuxSystem { home-manager = true; } {
    imports = [ self.nixosModules.default self.nixosModules.linux self.nixosModules.home stub ];
  };

  # Configuration of the bare host with extra modules
  bareWith = modules: (bare.extendModules { inherit modules; }).config;

  # Configuration of the home-manager host with extra modules
  withHomeWith = modules: (withHome.extendModules { inherit modules; }).config;
}

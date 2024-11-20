{ pkgs, lib, config, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  xerox_phaser_p3250 = pkgs.callPackage "${self}/packages/XeroxPhaser3250.nix" { };
in
{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Hardware tweaks
  hardware = {
    # µcode update
    cpu.amd.updateMicrocode = true;

    # Firmware
    enableAllFirmware = true;

    # Enable modesetting for nVidia
    nvidia.modesetting.enable = true;

    # Enable nVidia for containers (ie. docker)
    nvidia-container-toolkit.enable = true;

    # Use nVidia open source driver
    nvidia.open = true;

    # Enable Razer
    openrazer = {
      enable = true;
      keyStatistics = true;
      syncEffectsEnabled = true;
      devicesOffOnScreensaver = true;
    };

    steam-hardware.enable = true;

    # Enable bluetooth
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    # Enable 32bit OpenGL
    graphics = {
      enable32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.printing.drivers = with pkgs; [ xerox_phaser_p3250 ];

}

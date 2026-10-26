{ flake, lib, config, ... }:

{
  options.my.hardware.razer.enable = lib.mkEnableOption "Razer device support";

  config = lib.mkIf config.my.hardware.razer.enable {
    # Enable Razer
    hardware.openrazer = {
      enable = true;
      keyStatistics = true;
      syncEffectsEnabled = true;
      devicesOffOnScreensaver = true;
      users = [ flake.config.people.me ];
    };
  };
}

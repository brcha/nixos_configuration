{ flake, lib, config, ... }:

{
  # The switch is declared in options/, shared with home-manager
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

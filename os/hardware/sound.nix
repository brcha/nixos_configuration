{ pkgs, libs, flake, config, lib, ... }:

{
  options.my.hardware.sound.enable = lib.mkEnableOption "PipeWire sound";

  config = lib.mkIf config.my.hardware.sound.enable {
    # Enable pipewore
    #  sound.enable = false; # old style

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}

{ pkgs, libs, flake, config, ... }:

{
  # Enable pipewore
  sound.enable = false; # old style

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

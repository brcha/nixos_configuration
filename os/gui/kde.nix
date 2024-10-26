{ flake, pkgs, config, ... }:

{
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      options = "eurosign:e";
    };

    desktopManager = {
      plasma5 = {
        enable = true;
        phononBackend = "vlc";
        runUsingSystemd = true;
        useQtScaling = true;
      };
    };
  };

  services.libinput.enable = false; # libinput doesn't support mouse speed settings

  services.displayManager = {
    sddm.enable = true;

    defaultSession = "plasma";
  };


  programs = {
    kdeconnect.enable = true;
  };

  # Enable Gnome Keyring (to make skype work https://github.com/NixOS/nixpkgs/issues/74343)
  services.gnome.gnome-keyring.enable = true;

  # Build Gtk Icon cache
  gtk.iconCache.enable = true;
}

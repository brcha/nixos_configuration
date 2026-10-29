{ flake, pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.kde.enable {
    assertions = [{
      assertion = config.my.gui.enable;
      message = "my.kde.enable requires my.gui.enable";
    }];

    services.desktopManager = {
      plasma6 = {
        enable = true;
      };
    };

    services.xserver = {
      enable = true;

      # Keyboard defaults; a machine can set its own
      xkb = {
        layout = lib.mkDefault "us";
        options = lib.mkDefault "eurosign:e";
      };

      #      plasma5 = {
      #        enable = true;
      #        phononBackend = "vlc";
      #        runUsingSystemd = true;
      #        useQtScaling = true;
      #      };
    };

    services.libinput.enable = false; # libinput doesn't support mouse speed settings

    services.displayManager = {
      sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
      };

      # The Hyprland module overrides this on machines that import it
      defaultSession = lib.mkDefault "plasma";
    };


    programs = {
      kdeconnect.enable = true;
    };

    # No gnome-keyring: KWallet's ksecretd is the only Secret Service provider (#21)

    # Build Gtk Icon cache
    gtk.iconCache.enable = true;
  };
}

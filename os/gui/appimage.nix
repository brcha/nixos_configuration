{ lib, config, ... }:

{
  config = lib.mkIf config.my.gui.appimage {
    # appimage-run, registered with binfmt so AppImages run directly (./App.AppImage)
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}

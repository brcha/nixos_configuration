{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.communication (lib.mkMerge [
    {
      home.packages = available (with pkgs; [
        # Messaging
        discord
        telegram-desktop

        # Video conferencing
        unstable.zoom-us
        webex
      ]);
    }

    # Viber is the Flatpak com.viber.Viber, installed by hand
    (lib.mkIf pkgs.stdenv.isLinux {
      # The host font directory the sandbox sees is a tree of links into the Nix store
      xdg.dataFile."flatpak/overrides/com.viber.Viber".text = ''
        [Context]
        filesystems=/nix/store:ro
      '';

      # Viber's bundled Qt cannot load the KDE platform theme and the sandbox does not
      # read the host fontconfig, so it falls back to DejaVu Sans and spaces it badly.
      # Use the KDE font (kdeglobals) for the families it asks for.
      home.file.".var/app/com.viber.Viber/config/fontconfig/fonts.conf".text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <alias binding="strong"><family>sans-serif</family><prefer><family>Fira Sans</family></prefer></alias>
          <alias binding="strong"><family>system-ui</family><prefer><family>Fira Sans</family></prefer></alias>
          <alias binding="strong"><family>Segoe UI</family><prefer><family>Fira Sans</family></prefer></alias>
        </fontconfig>
      '';
    })
  ]);
}

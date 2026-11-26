{ pkgs, lib, config, ... }:

let
  blackwidow-colours = pkgs.callPackage ./blackwidow-colours.nix { };
in
{
  config = lib.mkIf config.my.hardware.razer.enable {
    home.packages = [ blackwidow-colours ];

    systemd.user.services.blackwidow-colours = {
      Unit = {
        Description = "Set the BlackWidow keyboard colour scheme";
        After = [ "openrazer-daemon.service" ];
        Wants = [ "openrazer-daemon.service" ];
      };
      Service = {
        Type = "oneshot";
        # Lets openrazer-daemon restore its saved effects first, so these colours win
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = lib.getExe blackwidow-colours;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}

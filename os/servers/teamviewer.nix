{ pkgs, config, lib, ... }:

{
  options.my.servers.teamviewer.enable = lib.mkEnableOption "TeamViewer";

  config = lib.mkIf config.my.servers.teamviewer.enable {
    services.teamviewer.enable = true;
  };
}

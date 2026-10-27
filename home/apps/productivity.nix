{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.productivity {
    home.packages = available
      (with pkgs; [
        # Documentation browser
        zeal

        # Notes
        joplin-desktop

        # Time tracking
        clockify

        # Office suite
        libreoffice-qt
      ])
    # Todo.txt manager GUI, only where its flake supports it (the CLI is in home/tools)
    ++ available [ pkgs.rtm.rtmapp ];
  };
}

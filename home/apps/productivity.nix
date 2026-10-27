{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.productivity {
    home.packages = available
      (with pkgs; [
        # Notes
        joplin-desktop

        # Time tracking
        clockify

        # Office suite
        libreoffice-qt
      ])
    # Documentation browser; the nixpkgs build fails on macOS (its qtwebengine dependency
    # cannot find the C++ standard headers), so Linux only for now
    ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.zeal ]
    # Todo.txt manager GUI, only where its flake supports it (the CLI is in home/tools)
    ++ available [ pkgs.rtm.rtmapp ];
  };
}

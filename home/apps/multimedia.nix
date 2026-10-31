{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.multimedia {
    home.packages = available
      (with pkgs; [
        # Video players
        mpv
        smplayer
        vlc

        # Video tools
        avidemux
        kdePackages.kdenlive
        mkvtoolnix

        # Audio
        lmms

        # Streaming
        obs-studio

        # Audio routing
        qpwgraph
      ])
    # The nixpkgs macOS build fails: Spotify's download URL has no version and the
    # file behind it changed, so its hash no longer matches. Linux only for now
    ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.spotify ];
  };
}

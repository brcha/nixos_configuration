{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.dev-tools {
    home.packages = available
      (with pkgs; [
        # Profiler GUI
        kdePackages.kcachegrind

        # Diff tool
        meld

        # Database GUIs
        dbeaver-bin
        pgmanage

        # Git GUIs
        qgit
        thicket
      ])
    # Linux-only, though their metadata does not show it: the Claude desktop app is
    # an FHS wrapper, the Grok Bot flake packages only the Linux AppImage, and KDiff3
    # and the heaptrack memory profiler need KDE frameworks
    ++ lib.optionals pkgs.stdenv.isLinux [
      pkgs.claude-desktop.claude-desktop-fhs
      pkgs.grok-bot
      pkgs.kdiff3
      pkgs.heaptrack
    ];

    # One keychain item for the Claude app in Plasma and Hyprland; Electron would
    # pick the KWallet API in Plasma and libsecret elsewhere, with different keys
    home.sessionVariables = lib.optionalAttrs pkgs.stdenv.isLinux {
      CLAUDE_PASSWORD_STORE = "gnome-libsecret";
    };
  };
}

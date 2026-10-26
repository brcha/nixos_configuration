{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.dev-tools {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform)
      (with pkgs; [
        # Profiler GUI
        kdePackages.kcachegrind

        # Diff tools
        kdiff3
        meld

        # Database GUIs
        dbeaver-bin
        pgmanage

        # Git GUIs
        qgit
        thicket
      ])
    # The Claude desktop app is built for Linux only (an FHS wrapper)
    ++ lib.optional pkgs.stdenv.isLinux pkgs.claude-desktop.claude-desktop-fhs;
  };
}

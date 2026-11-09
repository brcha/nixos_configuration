{ pkgs, lib, config, available, ... }:

{
  config = lib.mkIf config.my.apps.editors {
    home.packages = available (with pkgs; [
      # AI-native editor. Cursor's Electron picks the KDE 5 wallet API, which Plasma 6's kwalletd6 does not
      # serve; libsecret reaches KWallet through the Secret Service API instead
      (if stdenv.isLinux
      then unstable.code-cursor.override { commandLineArgs = "--password-store=gnome-libsecret"; }
      else unstable.code-cursor)

      # Neovim GUI
      neovide
    ]);
  };
}

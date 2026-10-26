{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.security {
    # Packages not built for this platform (Linux-only apps on the Mac) are left out
    home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
      # Privacy browser
      tor-browser

      # Password generation
      diceware

      # Password managers
      gopass
      gopass-jsonapi
      qtpass

      # Antivirus
      clamav
      clamtk

      # Cryptography and signing
      gnupg
      openssl
      signing-party

      # Smart card
      pcsc-tools
      pcsclite
    ]);
  };
}

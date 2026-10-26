{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.security {
    home.packages = with pkgs; [
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
    ];
  };
}

{ pkgs, lib, ... }:

{
  # Packages not built for this platform are left out
  home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) (with pkgs; [
    # Password generation
    diceware

    # Password manager
    gopass

    # Antivirus scanner
    clamav

    # Cryptography and signing
    gnupg
    openssl
    signing-party

    # Smart card
    pcsc-tools
    pcsclite
  ]);
}

{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
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

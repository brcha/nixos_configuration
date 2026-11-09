{ pkgs, lib, available, ... }:

{
  home.packages = available (with pkgs; [
    # Network scanner
    nmap

    # Download manager
    aria2

    # Network utilities
    dig
    inetutils
    socat
    wget
  ]);
}

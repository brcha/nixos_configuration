{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Database clients and GUIs
    dbeaver-bin
    pgmanage
    sqlite
  ];
}

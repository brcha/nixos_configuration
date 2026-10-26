{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.databases {
    home.packages = with pkgs; [
      # Database clients and GUIs
      dbeaver-bin
      pgmanage
      sqlite
    ];
  };
}

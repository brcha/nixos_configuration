{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.apps.jetbrains {
    home.packages = with pkgs; [
      jetbrains.clion
      jetbrains.datagrip
      jetbrains.goland
      jetbrains.pycharm
      jetbrains.rust-rover
      jetbrains.webstorm
    ];
  };
}

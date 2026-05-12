{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.pycharm
    jetbrains.rust-rover
    jetbrains.webstorm
  ];
}

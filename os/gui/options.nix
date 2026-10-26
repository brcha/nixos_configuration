{ lib, config, ... }:

{
  options.my.gui = import ../../options/group.nix lib config "gui" "the graphical desktop base" [
    "flatpak"
    "fonts"
    "torrents"
  ];
}

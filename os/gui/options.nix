{ lib, config, ... }:

{
  options.my.gui = import ../../lib/group.nix lib config "gui" "the graphical desktop base" [
    "flatpak"
    "fonts"
    "sshAgent"
    "torrents"
  ];
}

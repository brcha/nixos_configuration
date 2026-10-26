{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.vcs {
    home.packages = with pkgs; [
      # Non-git version control systems
      darcs
      mercurial
      pijul
      quilt
      subversion
    ];
  };
}

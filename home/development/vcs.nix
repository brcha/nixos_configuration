{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Non-git version control systems
    darcs
    mercurial
    pijul
    quilt
    subversion
  ];
}

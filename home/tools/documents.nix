{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # LaTeX
    rubber
    texlive.combined.scheme-full

    # Document conversion
    pandoc

    # Bibliography
    bibtex-tidy
  ];
}

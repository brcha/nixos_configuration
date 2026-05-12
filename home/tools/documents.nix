{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # LaTeX
    rubber
    texlive.combined.scheme-full

    # Document conversion
    pandoc
    pdftk

    # Bibliography
    bibtex-tidy
  ];
}

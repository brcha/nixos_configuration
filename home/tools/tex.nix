{ pkgs, lib, config, ... }:

{
  # A full TeX Live is several gigabytes, so machines that do no TeX work can leave it out
  config = lib.mkIf config.my.tools.tex {
    home.packages = with pkgs; [
      rubber
      texlive.combined.scheme-full

      # Bibliography
      bibtex-tidy
    ];
  };
}

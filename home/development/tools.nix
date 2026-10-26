{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.tools {
    home.packages = with pkgs; [
      # Documentation generators
      doxygen
      graphviz
      plantuml

      # Source analysis
      loccount

      # Formatters and linters
      cmake-format
      fantomas
      markdownlint-cli
      nixpkgs-fmt
      shfmt
      stylelint
      whatstyle
    ];
  };
}

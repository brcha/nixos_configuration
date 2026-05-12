{ pkgs, ... }:

{
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
    nixpkgs-fmt
    shfmt
    stylelint
    whatstyle
  ];
}

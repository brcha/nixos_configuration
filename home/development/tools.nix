{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.tools {
    home.packages = with pkgs; [
      # Documentation generators
      plantuml

      # Source analysis
      loccount

      # Benchmarking
      hyperfine

      # Formatters and linters
      markdownlint-cli
      nixpkgs-fmt
      shfmt
      whatstyle
    ];
  };
}

{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.haskell {
    home.packages = with pkgs; [
      ghc
      stack

      # Formatters
      haskellPackages.cabal-fmt
      stylish-haskell
    ];
  };
}

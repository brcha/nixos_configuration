{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghc
    stack

    # Formatters
    haskellPackages.cabal-fmt
    stylish-haskell
  ];
}

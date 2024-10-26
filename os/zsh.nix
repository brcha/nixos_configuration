{ flake, pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
  };
}

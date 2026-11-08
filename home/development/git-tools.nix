{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.git-tools {
    home.packages = with pkgs; [
      # Commit helpers
      commitizen
      pre-commit

      # Forge CLIs
      github-cli

      # Git extensions
      git-ignore
      git-town
      gitleaks
    ];
  };
}

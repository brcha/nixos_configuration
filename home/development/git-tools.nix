{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.git-tools {
    home.packages = with pkgs; [
      # Commit helpers
      commitizen
      git-absorb
      pre-commit

      # Changelog and release
      git-cliff

      # Forge CLIs
      gist
      github-cli
      glab

      # Git extensions
      git-ignore
      git-standup
      git-subrepo
      git-town
      gitflow
      gitleaks

      # Diff and review
      delta
    ];
  };
}

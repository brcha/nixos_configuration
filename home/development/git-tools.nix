{ pkgs, ... }:

{
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

    # GUI clients
    qgit
    thicket
  ];
}

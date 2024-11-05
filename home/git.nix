{ flake, pkgs, misc, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  me = flake.config.people.users.${flake.config.people.me};
in
{
  programs = {
    git = {
      enable = true;
      userName = me.name;
      userEmail = me.email;
      signing = {
        key = me.gitSignKey;
        signByDefault = true;
      };
      extraConfig = {
        features.manyFiles = true;
        init.defaultBranch = "main";
        gpg.format = me.gitSignFormat;
        push.default = "simple";
        pull.rebase = true;
        core.autocrlf = "input";
        status = {
          showuntrackedfiles = "all";
          submoduleSummary = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        rebase = {
          stat = true;
          autoStash = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        hooks = { copyrightholder = "${me.name} <${me.email}>"; };
        git-town = { sync-feature-strategy = "rebase"; };
        url = {
          "git://anongit.kde.org/" = { insteadOf = "kde:"; };
          "git@git.kde.org" = { pushInsteadOf = "kde:"; };
          "git@github.com:alliancels" = {
            insteadOf = "https://github.com/alliancels";
          };
        };
        include = {
          path = config.sops.secrets.git-town-token.path;
        };
      };
      ignores = [
        ".ccls-cache" # Clang C++ language server cache
        ".idea" # IntelliJ Idea
        ".direnv"
        "result"
      ];
      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
        };
      };
      lfs.enable = true;
      aliases = {
        l = "log --date-order --date=iso --graph --full-history --all --pretty=format:'%x08%x09%C(red)%h %C(cyan)%ad%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08%x08 %C(bold blue)%aN%C(reset)%C(bold yellow)%d %C(reset)%s'";
      };
    };
  };
}

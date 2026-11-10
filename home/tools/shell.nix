{ flake, pkgs, misc, lib, config, ... }:

let
  person = flake.config.people.users.${config.home.username};
in
{
  config = lib.mkMerge [
    {
      home = {
        sessionVariables = {
          "CODESTATS_API_KEY" =
            "$(cat ${config.sops.secrets.codestats-key.path})";
        }
        // lib.optionalAttrs (person.ledgerFile != null) { "LEDGER_FILE" = "$HOME/${person.ledgerFile}"; }
        // lib.optionalAttrs (person.todoFile != null) { "TODOTXT" = "$HOME/${person.todoFile}"; };

        sessionPath = [
          "$HOME/bin"
          "$HOME/.local/bin"
          "$HOME/.npm-global/bin"
          "$HOME/.cargo/bin"
        ];

        shellAliases = {
          cat = "bat --paging=never";
          less = ''bat --pager="less -RFX --mouse"'';
          wttr = ''curl wttr.in/${person.location.city}\?lang=sr\&m'';
          # Live ripgrep search in skim; the query is rerun on every keystroke
          rgs = "sk --ansi -i -c 'rg --color=always --line-number {q}'";
          # The same, with a preview of the matching file centred on the line
          rgsp = "sk --ansi -i -c 'rg --color=always --line-number {q}' --delimiter : --preview 'bat --color=always --highlight-line {2} {1}' --preview-window 'right:50%:+{2}-/2'";
        };

        language.base = "sr_RS.UTF-8";
      };

      programs = {
        zsh = {
          enable = true;
          enableCompletion = true;
          # Sends Code::Stats pulses for typing in the shell
          plugins = [{
            name = "code-stats-zsh";
            file = "codestats.plugin.zsh";
            src = flake.inputs.code-stats-zsh;
          }];
          initContent = ''
            # Enable git-town completion
            source <(git-town completions zsh)
            umask 077
          '';
          siteFunctions = {
            gitPruneBranches = ''
              for branch in $(git branch -vv | grep -e ': gone]' | awk -- '{print $1}')
              do
                echo -e "Pruning branch \"''${branch}\""
                git branch -D "''${branch}"
              done
            '';
          };
        };

        lsd = {
          enable = true;
        };
        # Fuzzy finder; also binds Ctrl-T (files), Ctrl-R (history) and Alt-C (cd) in zsh
        skim = {
          enable = true;
          enableZshIntegration = true;
        };
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        starship = {
          enable = true;
          settings = {
            add_newline = true;
            line_break.disabled = true;
            directory.truncation_symbol = "…/";
            right_format = "$time";
            time = {
              disabled = false;
              format = "$time ($style)";
              time_format = "%a %T";
            };
          };
        };
        ripgrep = {
          enable = true;
          arguments = [ "-S" ];
        };

        dircolors.enable = true;
        zoxide.enable = true;
        man.enable = true;
      };
    }

    # The desktop side: the KDE file dialogs, the Zen browser and XDG MIME exist on Linux only,
    # and only where the browser apps are installed (not on WSL, which has no GUI)
    (lib.mkIf (pkgs.stdenv.isLinux && config.my.apps.firefox) {
      home = {
        sessionVariables = {
          "DEFAULT_BROWSER" = "${pkgs.zen-browser}/bin/zen";
          "GTK_USE_PORTAL" = "1"; # to make Firefox-based browsers use KDE's file save/open dialogs
        };
        shellAliases.open = "kde-open5 $* &>/dev/null";
      };

      xdg = {
        mime = {
          enable = true;
        };
        mimeApps = {
          defaultApplications = {
            "text/html" = "zen.desktop";
            "x-scheme-handler/http" = "zen.desktop";
            "x-scheme-handler/https" = "zen.desktop";
          };
        };
      };
    })
  ];
}

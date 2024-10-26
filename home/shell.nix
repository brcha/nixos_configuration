{ pkgs, misc, lib, config, ... }:

{
  home = {
    sessionVariables = {
      "CODESTATS_API_KEY" =
        "$(cat ${config.sops.secrets.codestats-key.path})";
      "LEDGER_FILE" = "$HOME/Documents/Finansije/ledger/main.journal";
      "ANDROID_SDK_ROOT" = "$HOME/Android/Sdk";
      "NDK_VERSION" = "21.0.6113669";
      "NDK_HOME" = "$HOME/Android/Sdk/ndk/$NDK_VERSION";
      "DEFAULT_BROWSER" = "{pkgs.firefox}/bin/firefox";
      "GTK_USE_PORTAL" = "1"; # to make firefox use KDE's file save/open dialogs
    };

    sessionPath = [
      "$HOME/bin"
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.cargo/bin"
    ];

    shellAliases = {
      open = "kde-open5 $* &>/dev/null";
      cat = "bat --paging=never";
      less = ''bat --pager="less -RFX"'';
      wttr = ''curl wttr.in/Belgrade\?lang=sr\&m'';
    };

    language.base = "sr_RS.UTF-8";
  };

  # XDG Settings
  xdg = {
    mime = {
      enable = true;
    };
    mimeApps = {
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
  };

  home.packages = with pkgs; [
    zplug
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      zplug = {
        enable = true;
        plugins = [{
          name = "code-stats/code-stats-zsh";
          tags = [ "from:gitlab" "use:codestats.plugin.zsh" ];
        }];
      };
      initExtra = ''
        # Enable git-town completion
        source <(git-town completions zsh)
        umask 077
      '';
    };

    lsd = {
      enable = true;
      enableAliases = true;
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

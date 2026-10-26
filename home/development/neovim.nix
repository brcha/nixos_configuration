{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.my.dev.neovim {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = true;
      withRuby = true;

      # AstroNvim fetches its plugins at runtime through lazy.nvim, so none are listed here.
      # The SOPS key must be sourced before the bootstrap so code-stats-vim can read it.
      initLua = ''
        vim.cmd.source "${config.sops.secrets.codestats-key-neovim.path}"
      '' + builtins.readFile ./nvim/init.lua;
    };

    xdg.configFile."nvim/lua".source = ./nvim/lua;

    home.packages = with pkgs; [
      neovide

      # nvim-treesitter needs the CLI; providing it here keeps Mason from fetching it
      tree-sitter

      # Language servers without a language module of their own
      unstable.bash-language-server
      unstable.docker-compose-language-service
      unstable.dockerfile-language-server
      unstable.glsl_analyzer
      unstable.lemminx
      unstable.ltex-ls-plus
      unstable.lua-language-server
      unstable.nil
      unstable.sqls
      unstable.taplo
      unstable.vim-language-server
      unstable.yaml-language-server
    ];
  };
}

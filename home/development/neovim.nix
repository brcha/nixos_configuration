{ config, pkgs, ... }:
{
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
  ];
}

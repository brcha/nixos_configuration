{ flake, pkgs, misc, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = true;

      coc = { enable = true; };

      extraConfig = ''
        " Setup Code::Stats
        source ${config.sops.secrets.codestats-key-neovim.path}
        let g:airline_section_x = airline#section#create_right(['tagbar', 'filetype', '%{CodeStatsXp()}'])

        " Toggle nerdtree on ctrl+n
        map <C-n> :NERDTreeToggle<CR>

        " Setup color scheme
        set termguicolors
        set background=dark
        colorscheme tokyonight

        set viewoptions=cursor,folds,slash,unix

        " Securing gopass
        au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

        " Disable special handling of mouse
        set mouse = ""

        " Setup CoC
        inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
        inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

        let g:coc_global_extensions  = [ 'coc-clangd', 'coc-clang-format-style-options', 'coc-cmake' ]
        let g:coc_global_extensions += [ 'coc-class-css', 'coc-css', 'coc-cssmodules', 'coc-html', 'coc-ltex', 'coc-markdownlint', 'coc-svelte', '@yaegassy/coc-tailwindcss3', 'coc-tsserver' ]
        let g:coc_global_extensions += [ 'coc-docker' ]
        let g:coc_global_extensions += [ 'coc-explorer', 'coc-highlight', 'coc-lightbulb', 'coc-nav' ]
        let g:coc_global_extensions += [ 'coc-gist', 'coc-git' ]
        let g:coc_global_extensions += [ 'coc-glslx' ]
        let g:coc_global_extensions += [ 'coc-graphql', 'coc-sql', 'coc-xml', 'coc-yaml' ]
        let g:coc_global_extensions += [ '@yaegassy/coc-pylsp' ]
        let g:coc_global_extensions += [ 'coc-rust-analyzer', 'coc-toml' ]
        let g:coc_global_extensions += [ 'coc-sh' ]
        let g:coc_global_extensions += [ 'coc-vimlsp' ]

        " Config coc-explorer
        :nmap <space>e <Cmd>CocCommand explorer<CR>

        " Config coc-ltex for latex
        let g:coc_filetype_map = {'tex': 'latex'}

        " Setup neoformat on save
        augroup fmt
          autocmd!
          autocmd BufWritePre * undojoin | Neoformat
        augroup END

        " Setup neoformat formatters
        let g:neoformat_enabled_bib = ['bibtex-tidy']
        let g:neoformat_enabled_c = ['clang-format']
        let g:neoformat_enabled_cs = ['clang-format']
        let g:neoformat_enabled_cpp = ['clang-format']
        let g:neoformat_enabled_cabal = ['cabal-fmt']
        let g:neoformat_enabled_caddy = ['caddy_fmt']
        let g:neoformat_enabled_css = ['stylelint']
        let g:neoformat_enabled_dart = ['dartfmt']
        let g:neoformat_enabled_elm = ['elm-format']
        let g:neoformat_enabled_fsharp = ['fantomas']
        let g:neoformat_enabled_glsl = ['clang-format']
        let g:neoformat_enabled_haskell = ['stylish-haskell']
        let g:neoformat_enabled_html = ['prettier']
        let g:neoformat_enabled_javascript = ['prettier']
        let g:neoformat_enabled_javascriptreact = ['prettier']
        let g:neoformat_enabled_json = ['prettier']
        let g:neoformat_enabled_jsonc = ['prettier']
        let g:neoformat_enabled_kotlin = ['prettier']
        let g:neoformat_enabled_latex = ['lattexindent']
        let g:neoformat_enabled_less = ['stylelint']
        let g:neoformat_enabled_markdown = ['prettier']
        let g:neoformat_enabled_nix = ['nixpkgs-fmt']
        let g:neoformat_enabled_pandoc = ['pandoc']
        let g:neoformat_enabled_purescript = ['purty']
        let g:neoformat_enabled_python = ['autopep8', 'yapf', 'docformatter']
        let g:neoformat_enabled_rust = ['rustfmt']
        let g:neoformat_enabled_sass = ['stylelint']
        let g:neoformat_enabled_scss = ['stylelint']
        let g:neoformat_enabled_shell = ['shfmt']
        let g:neoformat_enabled_yaml = ['prettier']
        let g:neoformat_enabled_zsh = ['shfmt']
      '';

      plugins = with pkgs.vimPlugins; [
        vim-sensible
        vim-sleuth
        vim-airline
        vim-nix
        NeoSolarized
        ale
        nerdtree
        vim-ledger
        neoformat
        vim-wakatime
        vim-just
        #        vim-fsharp # BROKEN at the moment
        tokyonight-nvim

        {
          plugin = vim-plug;
          config = ''
            call plug#begin('~/.vim/plugged')

            Plug 'https://gitlab.com/code-stats/code-stats-vim.git'

            Plug 'zhimsel/vim-stay'

            call plug#end()
          '';
        }
      ];
    };
  };

  home.packages = with pkgs; [
    neovim-qt
    watchman # required by coc-class-css
  ];
}

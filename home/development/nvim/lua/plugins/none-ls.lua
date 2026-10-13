-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"
    local h = require "null-ls.helpers"
    local FORMATTING = require("null-ls.methods").internal.FORMATTING

    -- Formatters without a none-ls builtin; each reads stdin and writes stdout
    local function stdin_formatter(name, filetypes, command, args)
      return h.make_builtin {
        name = name,
        method = FORMATTING,
        filetypes = filetypes,
        generator_opts = { command = command, args = args, to_stdin = true },
        factory = h.formatter_factory,
      }
    end

    local formatting = null_ls.builtins.formatting

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- clangd formats c and cpp, so clang-format only covers what no server handles
      formatting.clang_format.with { filetypes = { "cs", "glsl" } },
      formatting.fantomas,
      formatting.nixpkgs_fmt,
      formatting.prettier.with {
        filetypes = {
          "css", "html", "javascript", "javascriptreact", "json", "jsonc", "less", "markdown", "scss", "typescript",
          "typescriptreact", "yaml",
        },
      },
      formatting.shfmt.with { filetypes = { "sh", "zsh" } },
      stdin_formatter("autopep8", { "python" }, "autopep8", { "-" }),
      stdin_formatter("bibtex-tidy", { "bib" }, "bibtex-tidy", {}),
      stdin_formatter("cabal-fmt", { "cabal" }, "cabal-fmt", {}),
      stdin_formatter("latexindent", { "tex" }, "latexindent", { "-g", "/dev/null", "-" }),
      stdin_formatter("stylish-haskell", { "haskell" }, "stylish-haskell", {}),
      null_ls.builtins.diagnostics.markdownlint,
    })
  end,
}

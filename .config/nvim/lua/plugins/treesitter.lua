return {
  -- treesitter playground
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "cmake",
        "cpp",
        "css",
        "fish",
        "gitignore",
        "go",
        "http",
        "python",
        "regex",
        "sql",
      },

      -- https://github.com/nvim-treesitter/playground#query-linter
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },

      playground = {
        enable = true,
        disable = {},
        -- debounced time for highlighting nodes in the playground from source code
        updatetime = 25,
        -- whether the query persists across vim sessions
        persist_queries = true,
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- install parsers from custom opts.ensure_installed
      if opts.ensure_installed and #opts.ensure_installed > 0 then
        require("nvim-treesitter").install(opts.ensure_installed)
        -- register and start parsers for filetypes
        for _, parser in ipairs(opts.ensure_installed) do
          local filetypes = parser -- In this case, parser is the filetype/language name
          vim.treesitter.language.register(parser, filetypes)

          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = filetypes,
            callback = function(event)
              vim.treesitter.start(event.buf, parser)
            end,
          })
        end
      end

      -- auto-install and start parsers for any buffer
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        callback = function(event)
          local bufnr = event.buf
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

          if filetype == "" then
            return
          end

          for _, filetypes in pairs(opts.ensure_installed) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return
            end
          end

          local parser_name = vim.treesitter.language.get_lang(filetype)
          if not parser_name then
            return
          end

          local parser_configs = require("nvim-treesitter.parsers")
          if not parser_configs[parser_name] then
            return
          end

          local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if not parser_installed then
            require("nvim-treesitter").install({ parser_name }):wait(30000)
          end

          parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if parser_installed then
            vim.treesitter.start(bufnr, parser_name)
          end
        end,
      })
    end,
  },
}

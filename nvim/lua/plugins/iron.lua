return {
  {
    "Vigemus/iron.nvim",
    event = "VeryLazy",

    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup({
        config = {
          scratch_repl = true,
          close_window_on_exit = true,

          repl_definition = {
            sh = {
              command = { "zsh" },
            },

            python = {
              command = {
                "ipython",
                "--no-autoindent",
                "-i",
                "-c",
                table.concat({
                  "ip = get_ipython()",
                  "ip.run_line_magic('load_ext', 'autoreload')",
                  "ip.run_line_magic('autoreload', '2')",
                }, "; "),
              },

              format = common.bracketed_paste_python,

              block_dividers = {
                "# %%",
                "#%%",
              },
            },
          },

          repl_filetype = function(_, ft)
            return ft
          end,

          dap_integration = true,

          repl_open_cmd = view.split.vertical.rightbelow("45%"),
        },

        keymaps = {
          toggle_repl = "<leader>rr",
          restart_repl = "<leader>rR",

          -- These only send code. Focus remains in the source buffer.
          send_motion = "<leader>sc",
          visual_send = "<leader>sc",
          send_file = "<leader>sf",
          send_line = "<leader>sl",
          send_paragraph = "<leader>sp",
          send_until_cursor = "<leader>su",
          send_mark = "<leader>sm",
          send_code_block = "<leader>sb",
          send_code_block_and_move = "<leader>sn",

          mark_motion = "<leader>mc",
          mark_visual = "<leader>mc",
          remove_mark = "<leader>md",

          cr = "<leader>s<cr>",
          interrupt = "<leader>s<space>",
          exit = "<leader>sq",
          clear = "<leader>cl",
        },

        highlight = {
          italic = true,
        },

        ignore_blank_lines = true,
      })

      -- Manually enter the REPL only when requested.
      vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>", {
        desc = "Focus REPL",
      })

      vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>", {
        desc = "Hide REPL",
      })
    end,
  },
}

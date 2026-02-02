return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = nil,
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_install = {},
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
    incremental_selection = {
        enable = false,
        keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
        },
    }
}

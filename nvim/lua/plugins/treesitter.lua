return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = nil,
    opts = {
      ensure_installed = {},
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = false,
      },
    },
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
        signs = false,
    },
    servers = {
      pylsp = {},
      html = {},
      cssls = {},
      tsserver = {},
    },
  },
}

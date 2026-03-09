-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set("n", "gd", function()
  require("telescope.builtin").lsp_definitions({ reuse_win = false })
end, { desc = "Goto Definition" })

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Line numbers
opt.relativenumber = true -- Relative line numbers

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- UI
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8
opt.signcolumn = "yes" -- Always show sign column
opt.cursorline = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Undo
opt.undofile = true
opt.undolevels = 10000

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

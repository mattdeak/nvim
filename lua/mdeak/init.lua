require("mdeak.remap")
require("mdeak.set")

local vim = vim
local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldnestmax = 10
opt.foldminlines = 1

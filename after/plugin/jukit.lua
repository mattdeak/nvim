vim.g.jukit_terminal = "kitty"

vim.keymap.set('n', '<leader><CR>', "<cmd>lua require'jukit'.send_line()<CR>", { noremap = true })

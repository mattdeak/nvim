local dap_python = require("dap-python")

local dap, dapui = require("dap"), require("dapui")

-- Python
dap_python.test_runner = "pytest"
dap_python.setup("~/.virtualenvs/debugpy/bin/python")

-- If we are ina python file, set the debugpy adapter keymaps
vim.keymap.set("n", "<leader>dt", "<cmd>lua require'dap-python'.test_method()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dc", "<cmd>lua require'dap-python'.test_class()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>df", "<cmd>lua require'dap-python'.test_file()<CR>", { noremap = true, silent = true })

-- UI
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

dapui.setup()


-- Remaps
vim.keymap.set("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<F2>", "<cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lp",
    "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
    { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>", { noremap = true, silent = true })

local lsp = require('lsp-zero').preset({
    name = 'minimal',
    set_lsp_keymaps = true,
    manage_nvim_cmp = true,
    suggest_lsp_servers = false,
})

local util = require('lspconfig.util')

lsp.preset("recommended")

lsp.ensure_installed({
    'tsserver',
    'lua_ls',
    'rust_analyzer',
    'pyright',
})

lsp.configure('ts_server', {
    settings = {
        typescript = {
            -- Disable tsserver formatting, use null-ls instead
            format = nil
        }
    }
})


-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

lsp.configure('pyright', {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = 'strict',
                reportUnknownMemberType = 'warning',
                reportUnknownParameterType = 'warning',
                reportUnknownVariableType = 'warning',
                reportUnknownArgumentType = 'warning',
            }
        }
    },
    root_dir = function(fname)
        local root_files = {
            'pyproject.toml',
            'pyrightconfig.json',
            ".git",
        }
        return util.root_pattern(unpack(root_files))(fname) or lsp.util.find_git_ancestor(fname)
    end
})

lsp.skip_server_setup("rust_analyzer")


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_format_on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                vim.lsp.buf.formatting_sync()
            end,
        })
    end
end


local lsp_remap_on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end

local lsp_on_attach = function(client, bufnr)
    lsp_remap_on_attach(client, bufnr)
    lsp_format_on_attach(client, bufnr)
end

lsp.on_attach(lsp_on_attach)

lsp.setup()

-- Rust tools

require('rust-tools').setup({
    server = {
        on_attach = lsp_on_attach,
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy"
                },
                -- Stop rust-analyzer from linting unused features
                -- TODO: should this be a toggle?
                cargo = {
                    allFeatures = true
                },
            }
        }
    }
})

require('null-ls').setup({
    sources = {
        require('null-ls').builtins.formatting.black,
        require('null-ls').builtins.formatting.isort,
        require('null-ls').builtins.diagnostics.pyproject_flake8,
        require('null-ls').builtins.diagnostics.jsonlint,
        require('null-ls').builtins.diagnostics.prettier,
    },
    on_attach = lsp_format_on_attach
})

vim.diagnostic.config({
    virtual_text = true
})

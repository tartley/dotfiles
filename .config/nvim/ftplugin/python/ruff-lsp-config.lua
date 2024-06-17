-- # Python LSP server config
--
-- ## Requires
--
-- * plugin nvim-lspconfig
-- * ruff on the PATH
--
-- ## Diagnostics
--
-- In Python files,
-- brief diagnostics (e.g. unused import) appear as "virtual text" on the relevant line.
-- Details appear in a "popup window" for cursor's current line.
--
--      ,d  Toggle diagnostics
--     [-d  Go to prev
--     ]-d  Go to next
--  <C-w>d  Display diagnostic in float (obsoleted by the auto popup)
--      ,D  Menu which offers to auto-fix current or all diagnostics
--
-- ## Formatting
--
--      gq  Builtin to format code under movement, which now uses this LSP.
--       Q  My map to format current para.
--      ,Q  My map to format whole doc.
--      ,D  Menu which offers to organize imports
--

require('lspconfig').ruff.setup{

    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        -- Cannot get this to work. Formatting uses 88 (ruff default).
        -- Projects configured with pyproject.toml, etc, correctly use the settings from that,
        -- But how can I set this on-the-fly for other standalone files?
        -- lineLength = 60,

        -- Cannot get this to work.
        -- lint = {
        --     select = {
        --         "ALL",
        --     },
        -- },

        args = {
            -- Any extra CLI arguments for `ruff` go here. This works!
            -- "--line-length=100",
        },

    },

}

-- toggle diagnostics
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.enable(vim.diagnostic.is_disabled())<cr>')
-- display code action menu (e.g. to ignore or apply auto-fixes)
vim.keymap.set('n', '<leader>D', '<cmd>lua vim.lsp.buf.code_action()<cr>')

-- Automatically show all current line diagnostics in a floating window.
vim.cmd(
    'autocmd CursorHold,CursorHoldI *.py lua vim.diagnostic.open_float({focusable=false})'
)
vim.o.updatetime = 250

-- Format on file save
vim.cmd(
    'autocmd BufWritePre *.py lua vim.lsp.buf.format({async=false})'
)

-- configure the floaty diagnostic messages
vim.diagnostic.config({
    float = {
        header ='',
        source = 'always',
    },
    signs = {
        float = {
            severity_sort = true,
        },
        severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
        },
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
            [vim.diagnostic.severity.WARN] = 'WarningMsg',
        },
    },
    virtual_text = {
        prefix = '● ',
    },
})


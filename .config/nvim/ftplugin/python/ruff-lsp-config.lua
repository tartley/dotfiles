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
             -- Cannot get this to work. Formatting uses 88 (ruff default).
             -- How can I set this in the way I have previously been setting textwidth?
             lineLength = 60,

        -- -- Any extra CLI arguments for `ruff` go here.
        -- args = {},

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

vim.diagnostic.config({
    float = {
        header ='',
        source = 'always',
    },
    signs = {
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

-- NOT the lua way to do this: Format on file save
-- AHA use 'vim.cmd()' to do this, see above.
-- autocmd BufWritePre *.py lua vim.lsp.buf.format({ async = false })


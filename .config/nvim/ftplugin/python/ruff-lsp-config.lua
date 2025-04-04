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

-- Vim's LSP should use the version of 'ruff' on our PATH, or if there is none,
-- fallback to a ruff we have installed in neovim virtualenv.
-- let $PATH = $PATH.':'.$HOME.'/.virtualenvs/neovim/bin/'
vim.env.PATH = vim.env.PATH .. ':' .. vim.env.HOME .. '/.virtualenvs/neovim/bin/'


-- Restore normal working of gqq to format text
local pylsp_on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
end

require('lspconfig').ruff.setup{

    init_options = {
        settings = {

            -- Config used for standalone files without a pyproject.toml, etc.
            lineLength = 80,

            -- Ruff's logging level
            -- see logfile with :lua vim.print(vim.lsp.get_log_path())
            -- logLevel = 'debug',

            -- don't know if this works
            -- lint = {
            --     select = {
            --         "ALL",
            --     },
            -- },
        }
    },

    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        args = {
            -- Any extra CLI arguments for `ruff` go here.
            -- "--line-length=80",
        },
    },

    on_attach = pylsp_on_attach,

}

-- toggle diagnostics
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.enable(vim.diagnostic.is_disabled())<cr>')
-- display code action menu (e.g. to ignore or apply auto-fixes)
vim.keymap.set('n', '<leader>D', '<cmd>lua vim.lsp.buf.code_action()<cr>')
-- Restart to dismiss erroneously lingering diagnostics, move cursor to dismiss floating window
vim.keymap.set('n', '<leader>r', '<cmd>LspRestart<cr>lh')

-- Automatically show all current line diagnostics in a floating window.
vim.cmd(
    'autocmd CursorHold,CursorHoldI *.py lua vim.diagnostic.open_float({focusable=false})'
)
vim.o.updatetime = 500

-- Format on file save
-- Commented because sometimes I do not want to do this (e.g. when editing Rackit code at work)
-- vim.cmd(
--     'autocmd BufWritePre *.py lua vim.lsp.buf.format({async=false})'
-- )

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
    virtual_text = false,
})


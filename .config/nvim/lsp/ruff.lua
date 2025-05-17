
vim.env.PATH = vim.env.PATH .. ':' .. vim.env.HOME .. '/.virtualenvs/neovim/bin/'

vim.cmd(
    'autocmd CursorHold *.py lua vim.diagnostic.open_float({focusable=false})'
)
vim.o.updatetime = 200

vim.diagnostic.config({
    -- virtual_lines = true,
    signs = false,
    float = {
        header = '',
        source = 'always',
    },
    update_in_insert = false,
})

-- format on save
vim.cmd(
    'autocmd BufWritePre *.py lua vim.lsp.buf.format({async=false})'
)

-- some built in keys:
-- [-d : prev diagnostic
-- ]-d : next diagnostic

-- <leader>d : toggle virtual lines
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<cr>')
-- <leader>D : toggle virtual text
vim.keymap.set('n', '<leader>D', '<cmd>lua vim.diagnostic.config({virtual_text=not vim.diagnostic.config().virtual_text})<cr>')
-- <leader>. code action menu (e.g. to ignore or apply auto-fixes)
vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<cr>')

-- Restore normal working of gqq to format text
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
end

py_root_files = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'Makefile',
    'requirements.txt',
    'Pipfile',
    '.git',
}
return {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = py_root_files,
    init_options = {
        settings = {
            extendSelect = {"E", "T", "I", "F", "W", "N"}
        }
    },
    on_attach = on_attach,
}


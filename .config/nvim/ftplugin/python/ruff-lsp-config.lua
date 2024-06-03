-- Python LSP server config
--
-- Requires nvim-lspconfig which is git cloned into ~/.config/nvim/..., and
--
--   pipx install ruff --python python3.12
--
-- # WORKING
--
-- Diagnostics appear in Python files, and not in other files
--
--     [-d Go to prev diagnostic
--     ]-d Go to next diagnostic
--  <C-w>d Display diagnostic in float
--
-- Formatting:
--
--      gq Format code under movement
--       Q Format current para
--     ??? Format whole doc
--
-- # NOT WORKING / TODO
--
-- Should I be using the beta ruff languages server instead of ruff-lsp?
-- It is intgegrated into ruff itself, so presumably 
-- What's the keybind to format a whole buffer? Other than 1GgqG
--
-- gd Go to definition
--    Only works for functions and classes.
--    While this purportedly has advantages over ctags, in practice it's not remotely as useful.
--
-- <C-X><C-O> Omni mode completion.
--    Only completes classes and functions though, not variables :-(
--
-- K Hover, ie. show info on function under cursor.
--   Never has any info to display.
--


vim.lsp.start({
  name = "Ruff Language Server",
  cmd = {"ruff", "server", "--preview"},
  -- root_dir = vim.fs.root(0, {'setup.py', 'pyproject.toml'}),
})

require('lspconfig').ruff.setup{}

-- Diagnostics
-- toggle diagnostics
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.enable(vim.diagnostic.is_disabled())<cr>')
-- display code action menu (e.g. to ignore or apply auto-fixes)
vim.keymap.set('n', 'df', '<cmd>lua vim.lsp.buf.code_action()<cr>')
-- rename symbol under cursor
vim.keymap.set('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>')


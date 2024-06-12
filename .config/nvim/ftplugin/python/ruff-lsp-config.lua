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
-- What's the keybind to format a whole buffer? Other than 1GgqG
--
-- gd Go to definition
--    While this purportedly has advantages over ctags,
--    it only works for functions and classes.
--    so in practice it's not as useful as what I had without LSP
--
-- <C-X><C-O> Omni mode completion.
--    Only completes classes and functions though, not variables :-(
--    in practice it's not as useful as what I had without LSP
--
-- K Hover, ie. show info on function under cursor.
--   Never has any info to display. I thing ruff server doesn't support this.

require('lspconfig').ruff.setup{}

-- toggle diagnostics
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.enable(vim.diagnostic.is_disabled())<cr>')
-- display code action menu (e.g. to ignore or apply auto-fixes)
vim.keymap.set('n', '<leader>D', '<cmd>lua vim.lsp.buf.code_action()<cr>')


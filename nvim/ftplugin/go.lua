-- Go uses real tabs (gofmt enforces it), unlike our spaces-based global default.
vim.bo.expandtab = false -- insert real \t, not spaces
vim.bo.shiftwidth = 0 -- 0 = follow tabstop for indent width
vim.bo.tabstop = 4 -- render each tab as 4 columns

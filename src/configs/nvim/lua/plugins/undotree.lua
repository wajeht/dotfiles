-- Native undo-tree visualizer: a built-in opt-in plugin (no third-party dep).
-- :Undotree toggles a window showing the branching undo history; moving the
-- cursor inside it travels the tree. Pairs with our persistent 'undofile'.
vim.cmd.packadd("nvim.undotree")

vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Toggle undo tree" })

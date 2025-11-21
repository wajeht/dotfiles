vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua" },
})

-- Keymaps
-- vim.keymap.set({ "n", "i", "v", "t", "c" }, "<D-p>", "<cmd>FzfLua git_files<cr>", { desc = "Toggle FzfLua git_files" })
vim.keymap.set({ "n", "i", "v", "t", "c" }, "<D-p>", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files in cwd" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Fuzzy find git files" })
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files in cwd" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy find recent files" })
vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua live_grep<cr>", { desc = "Find string in cwd" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua grep_cword<cr>", { desc = "Find string under cursor in cwd" })
vim.keymap.set("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", { desc = "Find keymaps" })

vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<cr>", { desc = "Find marks" })
vim.keymap.set("n", "<leader>fq", "<cmd>FzfLua quickfix<cr>", { desc = "Find quickfix" })
vim.keymap.set("n", "<leader>fl", "<cmd>FzfLua loclist<cr>", { desc = "Find loclist" })
vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Find diagnostics in document" })
vim.keymap.set("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Find diagnostics in workspace" })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua treesitter<cr>", { desc = "Find treesitter symbols" })
vim.keymap.set("n", "<leader>fz", "<cmd>FzfLua spell_suggest<cr>", { desc = "Spell suggestions" })
vim.keymap.set("n", "z=", "<cmd>FzfLua spell_suggest<cr>", { desc = "Spell suggestions" })
vim.keymap.set("n", "<leader>f/", "<cmd>FzfLua blines<cr>", { desc = "Search lines in current buffer" })

local actions = require("fzf-lua.actions")

-- Custom action to open files in non-terminal windows
local function smart_edit(selected, opts)
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_win_get_buf(current_win)

	local target_win = current_win
	if vim.bo[current_buf].buftype == "terminal" then
		-- Find first non-terminal window in current tab
		for _, win in ipairs(wins) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype ~= "terminal" then
				target_win = win
				break
			end
		end
		-- If all windows are terminals, create a new split
		if target_win == current_win then
			vim.cmd("vsplit")
			target_win = vim.api.nvim_get_current_win()
		end
	end

	vim.api.nvim_set_current_win(target_win)
	actions.file_edit(selected, opts)
end

require("fzf-lua").setup({
	defaults = {
		formatter = "path.filename_first",
		git_icons = false,
		file_icons = false,
		color_icons = false,
	},
	winopts = {
		height = 0.5,
		width = 0.6,
		row = 0.35,
		col = 0.50,
		preview = {
			hidden = "hidden",
			border = "border",
		},
	},
	hls = {
		border = "FloatBorder",
		preview_border = "FloatBorder",
	},
	keymap = {
		builtin = {
			["<C-k>"] = "preview-up",
			["<C-j>"] = "preview-down",
			["<M-p>"] = "toggle-preview",
		},
		fzf = {
			["ctrl-a"] = "toggle-all",
			-- ctrl-q removed from here to allow per-action configuration
		},
	},
	files = {
		-- prompt = "Files> ",
		multiprocess = true,
		find_opts = [[-type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/storage/logs/*' -not -path '*/storage/framework/*' -not -path '*/bootstrap/cache/*' -not -path '*/public/build/*' -not -path '*/public/hot/*' -not -name '*.min.js' -not -name '*.min.css' -not -name '.DS_Store' -not -name 'yarn.lock' -not -name 'package-lock.json' -not -name 'composer.lock']],
		fd_opts = "--color=never --type f --hidden --follow --exclude node_modules --exclude .git --exclude vendor --exclude 'storage/logs' --exclude 'storage/framework' --exclude 'bootstrap/cache' --exclude 'public/build' --exclude 'public/hot' --exclude '*.min.js' --exclude '*.min.css' --exclude '.DS_Store' --exclude 'yarn.lock' --exclude 'package-lock.json' --exclude 'composer.lock'",
		actions = {
			["default"] = smart_edit,
			["ctrl-q"] = actions.file_sel_to_qf,
			["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
		},
	},
	git = {
		files = {
			-- prompt = "Git Files> ",
			multiprocess = true,
			actions = {
				["default"] = smart_edit,
				["ctrl-q"] = actions.file_sel_to_qf,
				["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
			},
		},
	},
	grep = {
		-- prompt = "Rg> ",
		multiprocess = true,
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512 --glob '!node_modules' --glob '!.git' --glob '!vendor' --glob '!storage/logs' --glob '!storage/framework' --glob '!bootstrap/cache' --glob '!public/build' --glob '!public/hot' --glob '!*.min.js' --glob '!*.min.css' --glob '!.DS_Store' --glob '!yarn.lock' --glob '!package-lock.json' --glob '!composer.lock'",
		actions = {
			["default"] = smart_edit,
			["ctrl-q"] = actions.file_sel_to_qf,
			["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
		},
	},
	oldfiles = {
		-- prompt = "History> ",
		cwd_only = true,
		actions = {
			["default"] = smart_edit,
			["ctrl-q"] = actions.file_sel_to_qf,
			["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
		},
	},
	spell_suggest = {
		-- prompt = "Spell> ",
		winopts = {
			height = 0.3,
			width = 0.3,
		},
	},
	buffers = {
		-- prompt = "Buffers> ",
		actions = {
			["default"] = smart_edit,
			["ctrl-q"] = actions.buf_sel_to_qf,
			["alt-q"] = { fn = actions.buf_sel_to_qf, prefix = "select-all" },
		},
	},
	diagnostics = {
		actions = {
			["default"] = smart_edit,
			["ctrl-q"] = actions.file_sel_to_qf,
			["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
		},
	},
	blines = {
		actions = {
			["default"] = actions.buf_edit,
			["ctrl-q"] = actions.buf_sel_to_qf,
			["alt-q"] = { fn = actions.buf_sel_to_qf, prefix = "select-all" },
		},
	},
})

-- Set border color for fzf-lua window
vim.cmd([[highlight FloatBorder guifg=#444444]])

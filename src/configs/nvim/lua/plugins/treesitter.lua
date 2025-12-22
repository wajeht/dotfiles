vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Deferred treesitter loading to avoid UI blocking
-- Based on: https://www.reddit.com/r/neovim/comments/1klxlvu/remove_treesitter_delays_when_opening_files/

local ensure_installed = {
	"json",
	"javascript",
	"typescript",
	"tsx",
	"vue",
	"yaml",
	"html",
	"css",
	"markdown",
	"markdown_inline",
	"php",
	"bash",
	"lua",
	"vim",
	"go",
	"dockerfile",
	"gitignore",
	"sql",
	"vimdoc",
	"embedded_template",
}

local parsers_loaded = {}
local parsers_pending = {}
local parsers_failed = {}

local ns = vim.api.nvim_create_namespace("treesitter.deferred")

-- Filetypes to skip treesitter processing
local ignored_filetypes = { "lazy", "mason", "help", "qf", "man" }

---Start treesitter for the current buffer
---@param lang string
---@return boolean
local function start_treesitter(lang)
	local ok = pcall(vim.treesitter.start, 0, lang)
	if not ok then
		return false
	end

	-- Set fold expression to use treesitter
	vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

	return true
end

-- Defer parser loading using decoration provider
-- Parsers may take time to load (big binary files) so start them async
vim.api.nvim_set_decoration_provider(ns, {
	on_start = vim.schedule_wrap(function()
		if #parsers_pending == 0 then
			return false
		end

		for _, data in ipairs(parsers_pending) do
			if vim.api.nvim_win_is_valid(data.winnr) and vim.api.nvim_buf_is_valid(data.bufnr) then
				vim._with({ win = data.winnr, buf = data.bufnr }, function()
					if start_treesitter(data.lang) then
						parsers_loaded[data.lang] = true
					else
						parsers_failed[data.lang] = true
					end
				end)
			end
		end
		parsers_pending = {}
	end),
})

-- FileType autocmd to trigger deferred treesitter loading
vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		-- Skip ignored filetypes
		if vim.tbl_contains(ignored_filetypes, event.match) then
			return
		end

		local lang = vim.treesitter.language.get_lang(event.match)
		if not lang or parsers_failed[lang] then
			return
		end

		if parsers_loaded[lang] then
			-- Parser already loaded, start immediately
			start_treesitter(lang)
		else
			-- Defer parser loading to avoid UI block
			table.insert(parsers_pending, {
				lang = lang,
				winnr = vim.api.nvim_get_current_win(),
				bufnr = event.buf,
			})
		end
	end,
})

-- Command to install all configured parsers
vim.api.nvim_create_user_command("TSInstallAll", function()
	for _, lang in ipairs(ensure_installed) do
		vim.cmd("TSInstall " .. lang)
	end
end, {})

-- Fold settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Disable folding at startup

-- Filetype detection for template languages
vim.filetype.add({
	extension = {
		ejs = "embedded_template",
		html = "embedded_template",
	},
})

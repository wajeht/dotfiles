vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

-- Deferred treesitter loading to avoid UI blocking from parser binary loading
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
	"embedded_template", -- EJS, ERB, etc.
}

-- Track parser loading state
local parsers_loaded = {} -- Parsers that have been successfully loaded
local parsers_pending = {} -- Parsers waiting to be loaded
local parsers_failed = {} -- Parsers that failed to load

local ns = vim.api.nvim_create_namespace("treesitter.deferred")

-- Filetypes to skip treesitter processing
local ignored_filetypes = { "lazy", "mason", "help", "qf", "man" }

-- Start treesitter highlighting for the current buffer
---@param lang string
---@return boolean
local function start_treesitter(lang)
	local ok = pcall(vim.treesitter.start, 0, lang)
	if not ok then
		return false
	end
	vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
	return true
end

-- Defer parser binary loading using decoration provider
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

-- FileType autocmd to trigger deferred loading
vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		if vim.tbl_contains(ignored_filetypes, event.match) then
			return
		end

		local lang = vim.treesitter.language.get_lang(event.match)
		if not lang or parsers_failed[lang] then
			return
		end

		if parsers_loaded[lang] then
			start_treesitter(lang)
		else
			table.insert(parsers_pending, {
				lang = lang,
				winnr = vim.api.nvim_get_current_win(),
				bufnr = event.buf,
			})
		end
	end,
})

-- Auto-install missing parsers (deferred)
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = vim.schedule_wrap(function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = ensure_installed,
			sync_install = false, -- Async install to avoid race conditions
			auto_install = true, -- Auto-install missing parsers when entering buffer
			highlight = { enable = false }, -- Handled by deferred loading above
			indent = { enable = true }, -- Enable indentation
		})
	end),
})

-- Fold settings using treesitter
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

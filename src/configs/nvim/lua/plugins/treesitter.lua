vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local nvim_treesitter = require("nvim-treesitter")

local managed_languages = {
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

nvim_treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local parsers_loaded = {} -- Parsers that have been successfully loaded
local parsers_pending = {} -- Parsers waiting to be loaded
local parsers_failed = {} -- Parsers that failed to load

local ns = vim.api.nvim_create_namespace("treesitter.deferred")

local ignored_filetypes = { "lazy", "mason", "help", "qf", "man" }

---@param lang string
---@return boolean
local function start_treesitter(lang)
	local ok = pcall(vim.treesitter.start, 0, lang)
	if not ok then
		return false
	end
	vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { scope = "local" })
	return true
end

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

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		if vim.tbl_contains(ignored_filetypes, event.match) then
			return
		end

		local lang = vim.treesitter.language.get_lang(event.match)
		if not lang or parsers_failed[lang] then
			return
		end

		vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

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

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = vim.schedule_wrap(function()
		local installed = nvim_treesitter.get_installed()
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, managed_languages)

		if #missing == 0 then
			return
		end

		local ok, err = pcall(nvim_treesitter.install, missing, { summary = true })
		if not ok then
			vim.notify("nvim-treesitter install failed: " .. err, vim.log.levels.WARN)
		end
	end),
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Disable folding at startup

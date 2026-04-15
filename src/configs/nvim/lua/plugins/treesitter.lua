vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local nvim_treesitter = require("nvim-treesitter")

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

local ignored_filetypes = {
	lazy = true,
	mason = true,
	help = true,
	qf = true,
	man = true,
}

nvim_treesitter.setup()

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		nvim_treesitter.install(ensure_installed, { summary = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		if ignored_filetypes[event.match] then
			return
		end

		local lang = vim.treesitter.language.get_lang(event.match)
		if not lang then
			return
		end

		if not vim.treesitter.language.add(lang) then
			return
		end

		vim.treesitter.start(event.buf, lang)

		if vim.api.nvim_buf_get_name(event.buf):match("^diffview://") then
			return
		end

		if vim.treesitter.query.get(lang, "indents") ~= nil then
			vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

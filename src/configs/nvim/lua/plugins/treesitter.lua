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

nvim_treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local managed_languages = {}
for _, lang in ipairs(ensure_installed) do
	managed_languages[lang] = true
end

local installing = {}
local ignored_filetypes = {
	lazy = true,
	mason = true,
	help = true,
	qf = true,
	man = true,
}

---@param lang string
---@return boolean
local function parser_installed(lang)
	return vim.tbl_contains(nvim_treesitter.get_installed("parsers"), lang)
end

---@param lang string
---@return boolean
local function parser_available(lang)
	local ok, loaded = pcall(vim.treesitter.language.add, lang)
	return ok and loaded
end

---@param languages string[]
---@param opts table|nil
local function request_parser_install(languages, opts)
	local requested = {}

	for _, lang in ipairs(languages) do
		if managed_languages[lang] and not installing[lang] then
			installing[lang] = true
			table.insert(requested, lang)
		end
	end

	if #requested == 0 then
		return
	end

	vim.schedule(function()
		local ok, task = pcall(
			nvim_treesitter.install,
			requested,
			vim.tbl_extend("force", {
				summary = true,
			}, opts or {})
		)

		if not ok then
			for _, lang in ipairs(requested) do
				installing[lang] = nil
			end
			vim.notify("nvim-treesitter install failed: " .. task, vim.log.levels.WARN)
			return
		end

		if task and task.await then
			task:await(function()
				for _, lang in ipairs(requested) do
					installing[lang] = nil
				end
			end)
		else
			for _, lang in ipairs(requested) do
				installing[lang] = nil
			end
		end
	end)
end

local function install_missing_or_invalid_parsers()
	local missing = {}
	local invalid = {}

	for _, lang in ipairs(ensure_installed) do
		if not parser_installed(lang) then
			table.insert(missing, lang)
		elseif not parser_available(lang) then
			table.insert(invalid, lang)
		end
	end

	request_parser_install(missing)
	request_parser_install(invalid, { force = true })
end

local original_treesitter_start = vim.treesitter.start

vim.treesitter.start = function(bufnr, lang)
	local resolved_buf = vim._resolve_bufnr(bufnr)
	local resolved_lang = lang

	if not resolved_lang then
		local filetype = vim.bo[resolved_buf].filetype
		resolved_lang = filetype ~= "" and vim.treesitter.language.get_lang(filetype) or nil
	end

	if resolved_lang and not parser_available(resolved_lang) then
		request_parser_install({ resolved_lang }, parser_installed(resolved_lang) and { force = true } or nil)
		return
	end

	return original_treesitter_start(bufnr, lang)
end

---@param bufnr integer
---@param filetype string
local function attach_treesitter(bufnr, filetype)
	if ignored_filetypes[filetype] then
		return
	end

	local lang = vim.treesitter.language.get_lang(filetype)
	if not lang then
		return
	end

	if not parser_available(lang) then
		request_parser_install({ lang }, parser_installed(lang) and { force = true } or nil)
		return
	end

	vim.treesitter.start(bufnr, lang)

	if vim.api.nvim_buf_get_name(bufnr):match("^diffview://") then
		return
	end

	if vim.treesitter.query.get(lang, "indents") ~= nil then
		vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = install_missing_or_invalid_parsers,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		attach_treesitter(event.buf, event.match)
	end,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

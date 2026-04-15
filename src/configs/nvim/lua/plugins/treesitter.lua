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

local parsers_loaded = {} -- Parsers that have been successfully loaded
local parsers_pending = {} -- Parsers waiting to be loaded
local parsers_failed = {} -- Parsers that failed to load
local parsers_install_requested = {} -- Parsers already queued for install

local ns = vim.api.nvim_create_namespace("treesitter.deferred")

local ignored_filetypes = { "lazy", "mason", "help", "qf", "man" }

---@param lang string
---@return boolean
local function parser_installed(lang)
	return vim.tbl_contains(nvim_treesitter.get_installed("parsers"), lang)
end

---@param languages string[]
---@return string[]
local function missing_languages(languages)
	return vim.tbl_filter(function(lang)
		return not parser_installed(lang)
	end, languages)
end

---@param languages string[]
---@param wait_ms integer|nil
---@return boolean
local function install_languages(languages, wait_ms)
	if #languages == 0 then
		return true
	end

	local ok, task = pcall(nvim_treesitter.install, languages, { summary = true })
	if not ok then
		vim.notify("nvim-treesitter install failed: " .. task, vim.log.levels.WARN)
		return false
	end

	if wait_ms and task and task.wait then
		local wait_ok, success = pcall(function()
			return task:wait(wait_ms)
		end)
		if not wait_ok then
			vim.notify("nvim-treesitter install wait failed: " .. success, vim.log.levels.WARN)
			return false
		end
		return success ~= false
	end

	return true
end

---@param lang string
local function request_parser_install(lang)
	if not managed_languages[lang] or parser_installed(lang) or parsers_install_requested[lang] then
		return
	end

	parsers_install_requested[lang] = true
	vim.schedule(function()
		install_languages({ lang })
	end)
end

-- Bootstrap the managed parser list on fresh installs so core runtime features
-- like markdown hover rendering do not trip over missing parsers.
install_languages(missing_languages(ensure_installed), 300000)

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
				vim.api.nvim_win_call(data.winnr, function()
					vim.api.nvim_buf_call(data.bufnr, function()
						if start_treesitter(data.lang) then
							parsers_loaded[data.lang] = true
						elseif parser_installed(data.lang) then
							parsers_failed[data.lang] = true
						else
							request_parser_install(data.lang)
						end
					end)
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
		if not lang then
			return
		end

		if not parser_installed(lang) then
			request_parser_install(lang)
			return
		end

		if parsers_failed[lang] then
			return
		end

		-- Skip indentation for diffview buffers (read-only, don't need it)
		local bufname = vim.api.nvim_buf_get_name(event.buf)
		if not bufname:match("^diffview://") then
			vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = vim.schedule_wrap(function()
		local missing = missing_languages(ensure_installed)

		if #missing == 0 then
			return
		end

		install_languages(missing)
	end),
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Disable folding at startup

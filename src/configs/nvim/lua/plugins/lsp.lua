vim.diagnostic.config({
	float = { source = "if_many" },
	virtual_text = true,
	severity_sort = true,
})

-- Short alias so capability checks stay readable below.
local methods = vim.lsp.protocol.Methods

-- Completion menu: color the kind column like the matching syntax element.
local kind_hl = {
	Class = "Structure",
	Color = "Constant",
	Constant = "Constant",
	Constructor = "Function",
	Enum = "Structure",
	EnumMember = "Constant",
	Event = "Type",
	Field = "Identifier",
	File = "Directory",
	Folder = "Directory",
	Function = "Function",
	Interface = "Structure",
	Keyword = "Keyword",
	Method = "Function",
	Module = "Structure",
	Operator = "Keyword",
	Property = "Identifier",
	Reference = "Identifier",
	Snippet = "Special",
	Struct = "Structure",
	TypeParameter = "Type",
	Unit = "Number",
	Value = "Number",
	Variable = "Identifier",
}

-- Keep LspAttach reload-safe; sourcing this file again replaces the old autocmd.
local lsp_augroup = vim.api.nvim_create_augroup("custom_lsp", { clear = true })

-- Give the completion docs float the same rounded border as the menu. It
-- ignores 'winborder' and is created only after the server's docs resolve
-- (so a CompleteChanged autocmd fires too early to see it); vim.lsp.completion
-- creates it through this API, which is the one reliable hook.
local complete_set = vim.api.nvim__complete_set
if complete_set then
	vim.api.nvim__complete_set = function(...)
		local windata = complete_set(...)
		if type(windata) == "table" and windata.winid and vim.api.nvim_win_is_valid(windata.winid) then
			pcall(vim.api.nvim_win_set_config, windata.winid, { border = "rounded" })
		end
		return windata
	end
end

-- Built-in completion uses Vim's popup menu. These mappings only send completion
-- keys when the popup is visible, otherwise they fall back to the original key.
local function pum_keymap(visible_key, fallback_key)
	return function()
		if vim.fn.pumvisible() == 1 then
			return vim.keycode(visible_key)
		end
		return vim.keycode(fallback_key)
	end
end

-- LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_augroup,
	callback = function(ev)
		-- Detach LSP from diffview buffers (they're read-only git blobs)
		local bufname = vim.api.nvim_buf_get_name(ev.buf)
		if bufname:match("^diffview://") then
			vim.schedule(function()
				pcall(vim.lsp.buf_detach_client, ev.buf, ev.data.client_id)
			end)
			return
		end

		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if not client then
			return
		end

		-- Enable linked editing (e.g. rename both opening/closing HTML tags simultaneously)
		if client:supports_method(methods.textDocument_linkedEditingRange, ev.buf) then
			vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
		end

		-- Enable code lenses (run with grx)
		if client:supports_method(methods.textDocument_codeLens, ev.buf) then
			vim.lsp.codelens.enable(true, { bufnr = ev.buf })
		end

		-- Setup completion if client supports it
		if client:supports_method(methods.textDocument_completion, ev.buf) then
			-- Autotrigger only fires on the server's trigger characters; extend
			-- them with identifier characters so completion also pops while
			-- typing plain words (:h lsp-autocompletion). Emmet is excluded:
			-- it already letter-triggers natively and would flood every word
			-- with abbreviation noise.
			local provider = client.server_capabilities.completionProvider
			if provider and client.name ~= "emmet_language_server" then
				local triggers = {}
				for _, char in ipairs(provider.triggerCharacters or {}) do
					triggers[char] = true
				end
				for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
					triggers[char] = true
				end
				provider.triggerCharacters = vim.tbl_keys(triggers)
			end

			-- Enable LSP completion
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
				convert = function(item)
					local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or ""
					return {
						abbr = item.label:gsub("%b()", ""),
						kind = kind,
						kind_hlgroup = kind_hl[kind],
						menu = "", -- drop server detail text (e.g. emmet's "Unknown Emmet Abbreviation")
					}
				end,
				-- Same ordering as the default (fuzzy score, then the server's
				-- sortText) plus an alphabetical tiebreak the default lacks:
				-- members often share one sortText and table.sort is unstable,
				-- which scrambles e.g. `router.` member lists.
				cmp = function(a, b)
					local score_a, score_b = a._fuzzy_score or 0, b._fuzzy_score or 0
					if score_a ~= score_b then
						return score_a > score_b
					end
					local item_a = vim.tbl_get(a, "user_data", "nvim", "lsp", "completion_item") or {}
					local item_b = vim.tbl_get(b, "user_data", "nvim", "lsp", "completion_item") or {}
					local sort_a = item_a.sortText or item_a.label or a.word
					local sort_b = item_b.sortText or item_b.label or b.word
					if sort_a ~= sort_b then
						return sort_a < sort_b
					end
					return (item_a.label or a.word) < (item_b.label or b.word)
				end,
			})

			-- Completion keymaps
			vim.keymap.set("i", "<C-k>", pum_keymap("<C-p>", "<C-k>"), {
				buffer = ev.buf,
				expr = true,
				desc = "Select previous completion",
			})

			vim.keymap.set("i", "<C-j>", pum_keymap("<C-n>", "<C-j>"), {
				buffer = ev.buf,
				expr = true,
				desc = "Select next completion",
			})

			vim.keymap.set("i", "<C-Space>", function()
				if vim.fn.pumvisible() == 1 then
					-- If completion menu is open, show documentation for selected item
					vim.lsp.buf.hover()
				else
					-- Otherwise trigger completion
					vim.lsp.completion.get()
				end
			end, { buffer = ev.buf, desc = "Trigger completion or show docs" })

			vim.keymap.set("i", "<D-i>", function()
				vim.lsp.completion.get()
			end, { buffer = ev.buf, desc = "Trigger completion (alternative)" })

			vim.keymap.set("i", "<CR>", pum_keymap("<C-y>", "<CR>"), {
				buffer = ev.buf,
				expr = true,
				desc = "Accept completion",
			})

			vim.keymap.set("i", "<Tab>", pum_keymap("<C-y>", "<Tab>"), {
				buffer = ev.buf,
				expr = true,
				desc = "Select and accept completion",
			})
		end

		-- LSP keymaps
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
		end

		map("gD", vim.lsp.buf.declaration, "Go to declaration")

		map("gd", vim.lsp.buf.definition, "Show LSP definitions")

		map("<leader>D", vim.diagnostic.setloclist, "Show buffer diagnostics")

		map("<leader>d", vim.diagnostic.open_float, "Show line diagnostics")

		-- Native Neovim uses :lsp restart; without a name it restarts clients on the current buffer.
		map("<leader>rs", "<cmd>lsp restart<cr>", "Restart LSP")

		if client:supports_method(methods.textDocument_inlayHint, ev.buf) then
			map("<leader>hh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, "Toggle inlay hints")
		end

		if client:supports_method(methods.textDocument_codeLens, ev.buf) and vim.lsp.codelens.is_enabled then
			map("<leader>cl", function()
				vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, "Toggle code lenses")
		end
	end,
})

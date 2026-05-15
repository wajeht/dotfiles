vim.diagnostic.config({
	float = { source = "if_many" },
	virtual_text = true,
	severity_sort = true,
})

-- Short alias so capability checks stay readable below.
local methods = vim.lsp.protocol.Methods

-- Keep LspAttach reload-safe; sourcing this file again replaces the old autocmd.
local lsp_augroup = vim.api.nvim_create_augroup("custom_lsp", { clear = true })

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
			-- Enable LSP completion
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

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

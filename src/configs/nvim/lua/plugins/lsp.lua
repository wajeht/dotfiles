-- LSP servers are auto-enabled by mason.lua based on installed packages

-- Deferred diagnostic config to avoid startup blocking
vim.api.nvim_create_autocmd("LspAttach", {
	once = true,
	callback = function()
		vim.diagnostic.config({
			virtual_lines = false,
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})
	end,
})

-- LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Disable inlay hints by default (can be toggled with <leader>hh)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			vim.lsp.inlay_hint.enable(false)
		end

		-- Enable linked editing (e.g. rename both opening/closing HTML tags simultaneously)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_linkedEditingRange) then
			vim.lsp.linked_editing_range.enable(true, { bufnr = ev.buf, client_id = client.id })
		end

		-- Enable code lenses (run with grx)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
			if vim.lsp.codelens.enable then
				vim.lsp.codelens.enable(true, { bufnr = ev.buf, client_id = client.id })
			else
				pcall(vim.lsp.codelens.refresh, { bufnr = ev.buf })
				vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
					buffer = ev.buf,
					callback = function()
						pcall(vim.lsp.codelens.refresh, { bufnr = ev.buf })
					end,
					desc = "Refresh LSP code lenses",
				})
			end
		end

		-- Setup completion if client supports it
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
			-- Enable LSP completion
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

			-- Completion keymaps
			vim.keymap.set("i", "<C-k>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-p>"
				else
					return "<C-k>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Select previous completion" })

			vim.keymap.set("i", "<C-j>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-n>"
				else
					return "<C-j>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Select next completion" })

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

			vim.keymap.set("i", "<CR>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-y>"
				else
					return "<CR>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Accept completion" })

			vim.keymap.set("i", "<Tab>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-y>"
				else
					return "<Tab>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Select and accept completion" })
		end

		-- LSP keymaps
		local opts = { buffer = ev.buf, noremap = true, silent = true }

		opts.desc = "Go to declaration"
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP definitions"
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

		opts.desc = "Show buffer diagnostics"
		vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, opts)

		opts.desc = "Show line diagnostics"
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float({ border = "rounded" })
		end, opts)

		opts.desc = "Go to previous diagnostic"
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, opts)

		opts.desc = "Go to next diagnostic"
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)

		opts.desc = "Show documentation for what is under cursor"
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, opts)

		opts.desc = "Restart LSP"
		vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

		opts.desc = "Toggle inlay hints"
		vim.keymap.set("n", "<leader>hh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, opts)

		if vim.lsp.codelens.enable and vim.lsp.codelens.is_enabled then
			opts.desc = "Toggle code lenses"
			vim.keymap.set("n", "<leader>cl", function()
				vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, opts)
		end
	end,
})

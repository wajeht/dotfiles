-- Native LSP configuration
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Enable LSP servers
local servers = {
	"lua_ls",
	"gopls",
	"html",
	"cssls",
	"tailwindcss",
	"emmet_language_server",
	"intelephense",
	"vtsls",
}

for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end

-- LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Disable inlay hints by default (can be toggled with <leader>hh)
		if
			client
			and client.supports_method
			and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
		then
			vim.lsp.inlay_hint.enable(false)
		end

		-- Setup completion if client supports it
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
			vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
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

			vim.keymap.set("i", "<C-b>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-b>"
				else
					return "<C-b>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Scroll documentation up" })

			vim.keymap.set("i", "<C-f>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-f>"
				else
					return "<C-f>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Scroll documentation down" })

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

			vim.keymap.set("i", "<C-e>", function()
				if vim.fn.pumvisible() == 1 then
					return "<C-e>"
				else
					return "<C-e>"
				end
			end, { buffer = ev.buf, expr = true, desc = "Hide completion" })

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

		opts.desc = "Show LSP references"
		vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)

		opts.desc = "Go to declaration"
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP definitions"
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

		opts.desc = "Show LSP implementations"
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

		opts.desc = "Show LSP type definitions"
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

		opts.desc = "See available code actions"
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

		opts.desc = "Smart rename"
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		opts.desc = "Show buffer diagnostics"
		vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, opts)

		opts.desc = "Show line diagnostics"
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		opts.desc = "Go to previous diagnostic"
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, opts)

		opts.desc = "Go to next diagnostic"
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)

		opts.desc = "Show documentation for what is under cursor"
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		opts.desc = "Signature help"
		vim.keymap.set("i", "<C-S>", vim.lsp.buf.signature_help, opts)

		opts.desc = "Restart LSP"
		vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

		opts.desc = "Toggle inlay hints"
		vim.keymap.set("n", "<leader>hh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, opts)
	end,
})

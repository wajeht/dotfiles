return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local lspconfig = require("lspconfig")

		local keymap = vim.keymap

		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		end

		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		lspconfig["html"].setup({ capabilities = capabilities, on_attach = on_attach })

		-- TypeScript server with Vue plugin (Hybrid Mode Configuration)
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
					},
				},
				preferences = {
					-- Improve type inference for Express
					includePackageJsonAutoImports = "on",
					includeCompletionsForModuleExports = true,
					includeCompletionsForImportStatements = true,
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			settings = {
				typescript = {
					-- Better IntelliSense for Node.js/Express
					suggest = {
						includeCompletionsForModuleExports = true,
						includeCompletionsForImportStatements = true,
					},
					preferences = {
						includePackageJsonAutoImports = "on",
					},
				},
				javascript = {
					suggest = {
						includeCompletionsForModuleExports = true,
						includeCompletionsForImportStatements = true,
					},
				},
			},
		})

		lspconfig["gopls"].setup({ capabilities = capabilities, on_attach = on_attach })

		lspconfig["cssls"].setup({ capabilities = capabilities, on_attach = on_attach })

		lspconfig["tailwindcss"].setup({ capabilities = capabilities, on_attach = on_attach })

		lspconfig["emmet_language_server"].setup({ capabilities = capabilities, on_attach = on_attach })

		lspconfig["intelephense"].setup({ capabilities = capabilities, on_attach = on_attach })

		-- Vue Language Server (Official Hybrid Mode Configuration)
		lspconfig.volar.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		vim.diagnostic.config({
			virtual_text = true, -- Enable inline diagnostic messages
			signs = true, -- Show signs in the sign column
			underline = true, -- Underline the text with an issue
			update_in_insert = false, -- Don't update diagnostics in insert mode
			severity_sort = true, -- Sort diagnostics by severity
			float = {
				focusable = false,
				style = "minimal",
				source = "always",
				header = "",
				prefix = "",
			},
		})
	end,
}

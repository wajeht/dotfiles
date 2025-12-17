-- Vue Language Server config
-- Requires vtsls to be running for TypeScript support in .vue files
return {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "vue" },
	root_markers = { "vue.config.js", "vue.config.ts", "nuxt.config.js", "nuxt.config.ts", "package.json" },
	on_init = function(client)
		client.handlers["tsserver/request"] = function(_, result, context)
			local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })

			if #vtsls_clients == 0 then
				vim.notify(
					"Could not find vtsls client, vue_ls requires it for TypeScript support.",
					vim.log.levels.ERROR
				)
				return
			end

			local ts_client = vtsls_clients[1]
			local param = unpack(result)
			local id, command, payload = unpack(param)

			ts_client:exec_cmd({
				title = "vue_request_forward",
				command = "typescript.tsserverRequest",
				arguments = { command, payload },
			}, { bufnr = context.bufnr }, function(_, r)
				local response = r and r.body
				local response_data = { { id, response } }
				---@diagnostic disable-next-line: param-type-mismatch
				client:notify("tsserver/response", response_data)
			end)
		end
	end,
}

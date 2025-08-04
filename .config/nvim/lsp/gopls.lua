return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	settings = {
		gopls = {
			["ui.inlayhint.hints"] = {
				compositeLiteralFields = true,
				constantValues = true,
				parameterNames = true,
			},
		},
	},
}

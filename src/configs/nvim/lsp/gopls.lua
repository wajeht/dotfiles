return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gosum", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	settings = {
		gopls = {
			hints = {
				compositeLiteralFields = true,
				constantValues = true,
				parameterNames = true,
			},
		},
	},
}

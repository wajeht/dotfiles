return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = {
		"html",
		"blade",
		"svelte",
	},
	root_markers = { "package.json", ".git", "index.html" },
	init_options = { provideFormatter = true },
}

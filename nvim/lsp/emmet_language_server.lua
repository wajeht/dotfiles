return {
	cmd = { "emmet-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"scss",
		"less",
		"javascriptreact",
		"typescriptreact",
		"vue",
		"svelte",
		"blade",
		"embedded_template",
	},
	root_markers = { "package.json", "composer.json", ".git" },
	init_options = {
		includeLanguages = {
			blade = "html",
			embedded_template = "html",
		},
		showAbbreviationSuggestions = true,
		showExpandedAbbreviation = "always",
		showSuggestionsAsSnippets = false,
	},
}

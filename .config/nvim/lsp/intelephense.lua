return {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php" },
	root_markers = { "composer.json", "index.php", ".git" },
	settings = {
		intelephense = {
			hints = {
				parameterNames = true,
				parameterTypes = true,
				typeHints = true,
			},
		},
	},
}

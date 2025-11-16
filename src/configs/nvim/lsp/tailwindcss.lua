return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"scss",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"blade",
		"svelte",
	},
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"postcss.config.ts",
		"package.json",
		".git",
	},
	settings = {
		tailwindCSS = {
			emmetCompletions = true,
			validate = true,
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidScreen = "error",
				invalidVariant = "error",
				invalidConfigPath = "error",
				invalidTailwindDirective = "error",
				recommendedVariantOrder = "warning",
			},
			-- Tailwind class attributes configuration
			classAttributes = { "class", "className", "classList", "ngClass", ":class" },

			-- Experimental regex patterns to detect Tailwind classes in various syntaxes
			experimental = {
				classRegex = {
					-- tw`...` or tw("...")
					"tw`([^`]*)`",
					"tw\\(([^)]*)\\)",

					-- @apply directive inside SCSS / CSS
					"@apply\\s+([^;]*)",

					-- class and className attributes (HTML, JSX, Vue, Blade with :class)
					'class="([^"]*)"',
					'className="([^"]*)"',
					':class="([^"]*)"',

					-- Laravel @class directive e.g. @class([ ... ])
					"@class\\(([^)]*)\\)",
				},
			},
		},
	},
}

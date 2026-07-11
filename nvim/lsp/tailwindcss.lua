local config_files = {
	"tailwind.config.js",
	"tailwind.config.cjs",
	"tailwind.config.mjs",
	"tailwind.config.ts",
}

local function has_tailwind_package(package_json)
	local ok, lines = pcall(vim.fn.readfile, package_json)
	if not ok then
		return false
	end

	return table.concat(lines, "\n"):find('"tailwindcss"', 1, true) ~= nil
end

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
	root_dir = function(bufnr, on_dir)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local start = bufname ~= "" and bufname or vim.uv.cwd()

		-- Tailwind is expensive; avoid starting it in every generic JS/CSS project.
		local config_root = vim.fs.root(start, config_files)
		if config_root then
			on_dir(config_root)
			return
		end

		local package_json = vim.fs.find("package.json", { path = start, upward = true })[1]
		if package_json and has_tailwind_package(package_json) then
			on_dir(vim.fs.dirname(package_json))
		end
	end,
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

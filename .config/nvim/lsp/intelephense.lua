return {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php" },
	root_markers = { "composer.json", "index.php", ".git" },
	settings = {
		intelephense = {
			-- PHP stubs for better completions
			stubs = {
				"bcmath",
				"bz2",
				"calendar",
				"Core",
				"curl",
				"date",
				"dom",
				"fileinfo",
				"filter",
				"gd",
				"gettext",
				"hash",
				"iconv",
				"intl",
				"json",
				"libxml",
				"mbstring",
				"openssl",
				"pcntl",
				"pcre",
				"PDO",
				"pdo_mysql",
				"pdo_sqlite",
				"Phar",
				"posix",
				"readline",
				"Reflection",
				"session",
				"SimpleXML",
				"soap",
				"sockets",
				"sodium",
				"SPL",
				"standard",
				"superglobals",
				"tokenizer",
				"xml",
				"xmlreader",
				"xmlwriter",
				"zip",
				"zlib",
			},
			-- File settings
			files = {
				maxSize = 5000000,
				associations = { "*.php", "*.phtml" },
				exclude = {
					"**/vendor/**",
					"**/node_modules/**",
					"**/.git/**",
					"**/.svn/**",
					"**/.hg/**",
					"**/CVS/**",
					"**/.DS_Store/**",
					"**/bower_components/**",
				},
			},
			-- Environment settings for better path resolution
			environment = {
				phpVersion = "8.2", -- Adjust to your PHP version
			},
			-- Diagnostics settings
			diagnostics = {
				enable = true,
				run = "onType", -- or "onSave"
			},
			-- Format settings
			format = {
				enable = false, -- Usually handled by prettier or other formatters
			},
		},
	},
}

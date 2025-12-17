vim.pack.add({
	{ src = "https://github.com/williamboman/mason.nvim" },
})

require("mason").setup()

-- Auto-install LSPs without mason-lspconfig (deferred for faster startup)
-- Names must be Mason package names
local ensure_installed = {
	"lua-language-server",
	"gopls",
	"html-lsp",
	"css-lsp",
	"tailwindcss-language-server",
	"intelephense",
	"vtsls",
	"vue-language-server",
	"emmet-language-server",
}

vim.schedule(function()
	local installed_package_names = require("mason-registry").get_installed_package_names()
	for _, v in ipairs(ensure_installed) do
		if not vim.tbl_contains(installed_package_names, v) then
			vim.cmd(":MasonInstall " .. v)
		end
	end
end)

-- Load custom LSP configs from lsp/ directory
local function load_lsp_config(lsp_name)
	local ok, config = pcall(require, "lsp." .. lsp_name)
	if ok then
		return config
	end
	return nil
end

-- Auto-enable all Mason-installed LSPs
local installed_packages = require("mason-registry").get_installed_packages()
for _, pack in ipairs(installed_packages) do
	-- Only process packages that have LSP configuration
	if pack.spec.neovim and pack.spec.neovim.lspconfig then
		local lsp_name = pack.spec.neovim.lspconfig
		local custom_config = load_lsp_config(lsp_name)

		if custom_config then
			vim.lsp.enable(lsp_name, custom_config)
		else
			vim.lsp.enable(lsp_name)
		end
	end
end

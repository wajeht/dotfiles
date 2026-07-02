vim.pack.add({
	{ src = "https://github.com/williamboman/mason.nvim" },
})

require("mason").setup()

local registry = require("mason-registry")

-- Names must be Mason package names.
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

local function enable_lsp_for_package(pack)
	if pack.spec.neovim and pack.spec.neovim.lspconfig then
		vim.lsp.enable(pack.spec.neovim.lspconfig)
	end
end

local function install_missing_packages()
	registry.refresh(function(success)
		if not success then
			vim.notify("Mason registry refresh failed", vim.log.levels.WARN)
			return
		end

		for _, package_name in ipairs(ensure_installed) do
			local ok, pack = pcall(registry.get_package, package_name)

			if ok and pack:is_installed() then
				enable_lsp_for_package(pack)
			elseif ok and not pack:is_installing() then
				pack:install({}, function(install_success, result)
					if install_success then
						vim.schedule(function()
							enable_lsp_for_package(pack)
						end)
					else
						vim.schedule(function()
							vim.notify(
								("Mason failed to install %s: %s"):format(package_name, tostring(result)),
								vim.log.levels.ERROR
							)
						end)
					end
				end)
			elseif not ok then
				vim.notify(("Mason package not found: %s"):format(package_name), vim.log.levels.WARN)
			end
		end
	end)
end

vim.schedule(install_missing_packages)

-- Defer LSP enabling to avoid startup blocking
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = vim.schedule_wrap(function()
		-- Auto-enable all Mason-installed LSPs
		local installed_packages = registry.get_installed_packages()
		for _, pack in ipairs(installed_packages) do
			enable_lsp_for_package(pack)
		end
	end),
})

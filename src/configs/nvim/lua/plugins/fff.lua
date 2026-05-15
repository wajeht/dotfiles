vim.pack.add({
	{ src = "https://github.com/dmtrKovalenko/fff.nvim" },
})

-- vim.pack needs an explicit post-install/update hook so the native binary exists.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("fff_pack_install", { clear = true }),
	callback = function(ev)
		local data = ev.data
		if not data or not data.spec then
			return
		end

		local name = data.spec.name
		if not name and data.spec.src then
			name = data.spec.src:match("/([^/]+)%.git$") or data.spec.src:match("/([^/]+)$")
		end

		local kind = data.kind
		if name ~= "fff.nvim" or (kind ~= "install" and kind ~= "update") then
			return
		end

		if not data.active then
			vim.cmd.packadd("fff.nvim")
		end

		require("fff.download").download_or_build_binary()
	end,
})

vim.g.fff = {
	prompt = "> ",
	layout = {
		height = 0.5,
		width = 0.6,
		prompt_position = "top",
	},
	preview = {
		enabled = false,
	},
	keymaps = {
		preview_scroll_up = "<C-k>",
		preview_scroll_down = "<C-j>",
		send_to_quickfix = { "<C-q>", "<M-q>" },
	},
}

local function ensure_fff_binary()
	local ok, download = pcall(require, "fff.download")
	if not ok then
		return
	end

	local binary_path = download.get_binary_path()
	if vim.uv.fs_stat(binary_path) then
		return
	end

	download.ensure_downloaded({}, function(success, err)
		if success then
			return
		end

		vim.schedule(function()
			vim.notify(
				"fff.nvim binary is missing. Run :lua require('fff.download').download_or_build_binary()\n"
					.. (err or "unknown error"),
				vim.log.levels.WARN
			)
		end)
	end)
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("fff_binary_bootstrap", { clear = true }),
	once = true,
	callback = ensure_fff_binary,
})

vim.keymap.set({ "n", "i", "v", "t", "c" }, "<D-p>", function()
	require("fff").find_files()
end, { desc = "Find repository files" })

vim.keymap.set("n", "<leader>fg", function()
	require("fff").find_files()
end, { desc = "Find repository files" })

vim.keymap.set("n", "<leader>ff", function()
	require("fff").find_files()
end, { desc = "Find files in cwd" })

vim.keymap.set("n", "<leader>fs", function()
	require("fff").live_grep()
end, { desc = "Find string in cwd" })

vim.keymap.set("n", "<leader>fc", function()
	require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "Find string under cursor in cwd" })

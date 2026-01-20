local function get_license_key()
	local license_path = os.getenv("HOME") .. "/intelephense/license.txt"
	local f = io.open(license_path, "rb")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return string.gsub(content, "%s+", "")
end

return {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php", "blade" },
	root_markers = { "composer.json", "index.php", ".git" },
	init_options = {
		licenceKey = get_license_key(),
	},
}

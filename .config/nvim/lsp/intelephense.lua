return {
   cmd = { "intelephense", "--stdio" },
   filetypes = { "php", "blade" },
   root_markers = { "composer.json", "index.php", ".git" },
   init_options = {
       licenceKey = (function()
           local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
           local content = f:read("*a")
           f:close()
           return string.gsub(content, "%s+", "")
       end)(),
   },
}

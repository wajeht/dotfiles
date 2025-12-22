-- Based on Mofiqul/vscode.nvim with custom modifications

local M = {}

-- Color palette (VSCode Dark)
local c = {
	-- Base colors
	bg = "NONE", -- Transparent
	fg = "#D4D4D4",
	cursor = "#AEAFAD",
	selection = "#264F78",

	-- UI elements
	line_nr = "#5A5A5A",
	line_nr_dim = "#28292c",
	cursor_line = "#2A2A2A",
	popup_bg = "#000000",
	popup_border = "#5a5a5a",
	search = "#613315",
	search_current = "#515c6a",

	-- Syntax colors
	gray = "#808080",
	violet = "#646695",
	orange = "#CE9178",
	blue = "#569CD6",
	light_blue = "#9CDCFE",
	green = "#6A9955",
	blue_green = "#4EC9B0",
	light_green = "#B5CEA8",
	red = "#F44747",
	light_red = "#D16969",
	yellow = "#DCDCAA",
	yellow_orange = "#D7BA7D",
	pink = "#C586C0",

	-- Git/Diff (matching VSCode style with transparency)
	diff_add_line = "#234023", -- added line background (green tint)
	diff_delete_line = "#402323", -- deleted line background (red tint - more visible)
	diff_add_text = "#2e4d2e", -- inline added text
	diff_delete_text = "#4d2e2e", -- inline deleted text
	-- For gitsigns gutter indicators
	diff_add = "#587c0c", -- green for added
	diff_delete = "#94151b", -- red for deleted
	diff_change = "#0c7d9d", -- blue for changed

	-- Misc
	white = "#ffffff",
	dim = "#444444",
}

local function set_highlights()
	local hl = vim.api.nvim_set_hl

	-- Editor UI
	hl(0, "Normal", { fg = c.fg, bg = c.bg })
	hl(0, "NormalNC", { fg = c.fg, bg = c.bg })
	hl(0, "NormalFloat", { fg = c.fg, bg = "NONE" })
	hl(0, "FloatBorder", { fg = c.popup_border, bg = "NONE" })
	hl(0, "FloatTitle", { fg = c.fg, bg = "NONE" })
	hl(0, "Cursor", { fg = c.cursor, bg = c.cursor })
	hl(0, "CursorLine", { bg = c.cursor_line })
	hl(0, "CursorColumn", { bg = c.cursor_line })
	hl(0, "ColorColumn", { bg = c.cursor_line })
	hl(0, "Visual", { bg = c.selection })
	hl(0, "VisualNOS", { bg = c.selection })

	-- Line numbers
	hl(0, "LineNr", { fg = c.line_nr_dim, bg = "NONE" })
	hl(0, "LineNrAbove", { fg = c.line_nr_dim, bg = "NONE" })
	hl(0, "LineNrBelow", { fg = c.line_nr_dim, bg = "NONE" })
	hl(0, "CursorLineNr", { fg = c.fg, bg = "NONE" })
	hl(0, "SignColumn", { fg = c.fg, bg = "NONE" })

	-- Search
	hl(0, "Search", { bg = c.search })
	hl(0, "IncSearch", { bg = c.search_current })
	hl(0, "CurSearch", { bg = c.search_current })
	hl(0, "Substitute", { bg = c.search })

	-- Statusline
	hl(0, "StatusLine", { fg = c.dim, bg = "NONE" })
	hl(0, "StatusLineNC", { fg = c.dim, bg = "NONE" })
	hl(0, "WinSeparator", { fg = c.dim, bg = "NONE" })
	hl(0, "VertSplit", { fg = c.dim, bg = "NONE" })

	-- Tabs
	hl(0, "TabLine", { fg = c.dim, bg = "NONE" })
	hl(0, "TabLineFill", { bg = "NONE" })
	hl(0, "TabLineSel", { fg = c.white, bg = "NONE" })

	-- Pmenu (completion)
	hl(0, "Pmenu", { fg = c.fg, bg = "NONE" })
	hl(0, "PmenuSel", { bg = "#03395e" })
	hl(0, "PmenuSbar", { bg = "NONE" })
	hl(0, "PmenuThumb", { bg = c.dim })
	hl(0, "PmenuBorder", { fg = c.dim })

	-- Whitespace/Special
	hl(0, "SpecialKey", { fg = c.line_nr_dim })
	hl(0, "NonText", { fg = c.line_nr_dim })
	hl(0, "Whitespace", { fg = c.line_nr_dim })
	hl(0, "EndOfBuffer", { fg = c.line_nr_dim })

	-- Fold
	hl(0, "Folded", { fg = c.gray, bg = "NONE" })
	hl(0, "FoldColumn", { fg = c.gray, bg = "NONE" })

	-- Diff (VSCode-style: subtle backgrounds with transparency)
	hl(0, "DiffAdd", { bg = c.diff_add_line, blend = 50 })
	hl(0, "DiffChange", { bg = c.diff_add_line, blend = 50 })
	hl(0, "DiffDelete", { fg = "#5a3535", bg = c.diff_delete_line, blend = 50 }) -- match bg color
	hl(0, "DiffText", { bg = c.diff_add_text, blend = 30 })

	-- Diagnostics
	hl(0, "DiagnosticError", { fg = c.red })
	hl(0, "DiagnosticWarn", { fg = c.yellow })
	hl(0, "DiagnosticInfo", { fg = c.blue })
	hl(0, "DiagnosticHint", { fg = c.blue_green })
	hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = c.red })
	hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
	hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
	hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = c.blue_green })

	-- Syntax (legacy vim groups)
	hl(0, "Comment", { fg = c.green })
	hl(0, "Constant", { fg = c.blue })
	hl(0, "String", { fg = c.orange })
	hl(0, "Character", { fg = c.orange })
	hl(0, "Number", { fg = c.light_green })
	hl(0, "Boolean", { fg = c.blue })
	hl(0, "Float", { fg = c.light_green })
	hl(0, "Identifier", { fg = c.light_blue })
	hl(0, "Function", { fg = c.yellow })
	hl(0, "Statement", { fg = c.pink })
	hl(0, "Conditional", { fg = c.pink })
	hl(0, "Repeat", { fg = c.pink })
	hl(0, "Label", { fg = c.pink })
	hl(0, "Operator", { fg = c.fg })
	hl(0, "Keyword", { fg = c.pink })
	hl(0, "Exception", { fg = c.pink })
	hl(0, "PreProc", { fg = c.pink })
	hl(0, "Include", { fg = c.pink })
	hl(0, "Define", { fg = c.pink })
	hl(0, "Macro", { fg = c.pink })
	hl(0, "PreCondit", { fg = c.pink })
	hl(0, "Type", { fg = c.blue })
	hl(0, "StorageClass", { fg = c.blue })
	hl(0, "Structure", { fg = c.blue_green })
	hl(0, "Typedef", { fg = c.blue })
	hl(0, "Special", { fg = c.yellow_orange })
	hl(0, "SpecialChar", { fg = c.yellow_orange })
	hl(0, "Tag", { fg = c.blue })
	hl(0, "Delimiter", { fg = c.fg })
	hl(0, "SpecialComment", { fg = c.green })
	hl(0, "Debug", { fg = c.red })
	hl(0, "Underlined", { underline = true })
	hl(0, "Error", { fg = c.red })
	hl(0, "Todo", { fg = c.yellow_orange, bold = true })

	-- TreeSitter
	hl(0, "@comment", { link = "Comment" })
	hl(0, "@comment.note", { fg = c.blue_green, bold = true })
	hl(0, "@comment.warning", { fg = c.yellow_orange, bold = true })
	hl(0, "@comment.error", { fg = c.red, bold = true })
	hl(0, "@constant", { fg = c.blue })
	hl(0, "@constant.builtin", { fg = c.blue })
	hl(0, "@constant.macro", { fg = c.blue })
	hl(0, "@string", { fg = c.orange })
	hl(0, "@string.regex", { fg = c.orange })
	hl(0, "@string.escape", { fg = c.yellow_orange })
	hl(0, "@string.special", { fg = c.yellow_orange })
	hl(0, "@character", { fg = c.orange })
	hl(0, "@number", { fg = c.light_green })
	hl(0, "@boolean", { fg = c.blue })
	hl(0, "@float", { fg = c.light_green })
	hl(0, "@function", { fg = c.yellow })
	hl(0, "@function.builtin", { fg = c.yellow })
	hl(0, "@function.macro", { fg = c.yellow })
	hl(0, "@function.call", { fg = c.yellow })
	hl(0, "@function.method", { fg = c.yellow })
	hl(0, "@function.method.call", { fg = c.yellow })
	hl(0, "@method", { fg = c.yellow })
	hl(0, "@method.call", { fg = c.yellow })
	hl(0, "@constructor", { fg = c.blue })
	hl(0, "@parameter", { fg = c.light_blue })
	hl(0, "@keyword", { fg = c.blue })
	hl(0, "@keyword.function", { fg = c.blue })
	hl(0, "@keyword.operator", { fg = c.pink })
	hl(0, "@keyword.return", { fg = c.pink })
	hl(0, "@keyword.conditional", { fg = c.pink })
	hl(0, "@keyword.repeat", { fg = c.pink })
	hl(0, "@keyword.exception", { fg = c.pink })
	hl(0, "@keyword.import", { fg = c.pink })
	hl(0, "@conditional", { fg = c.pink })
	hl(0, "@repeat", { fg = c.pink })
	hl(0, "@label", { fg = c.pink })
	hl(0, "@operator", { fg = c.fg })
	hl(0, "@exception", { fg = c.pink })
	hl(0, "@variable", { fg = c.light_blue })
	hl(0, "@variable.builtin", { fg = c.blue })
	hl(0, "@variable.parameter", { fg = c.light_blue })
	hl(0, "@variable.member", { fg = c.light_blue })
	hl(0, "@type", { fg = c.blue_green })
	hl(0, "@type.builtin", { fg = c.blue })
	hl(0, "@type.qualifier", { fg = c.blue })
	hl(0, "@type.definition", { fg = c.blue_green })
	hl(0, "@storageclass", { fg = c.blue })
	hl(0, "@structure", { fg = c.blue_green })
	hl(0, "@namespace", { fg = c.blue_green })
	hl(0, "@module", { fg = c.blue_green })
	hl(0, "@include", { fg = c.pink })
	hl(0, "@preproc", { fg = c.pink })
	hl(0, "@define", { fg = c.pink })
	hl(0, "@macro", { fg = c.pink })
	hl(0, "@punctuation.delimiter", { fg = c.fg })
	hl(0, "@punctuation.bracket", { fg = c.fg })
	hl(0, "@punctuation.special", { fg = c.fg })
	hl(0, "@tag", { fg = c.blue })
	hl(0, "@tag.attribute", { fg = c.light_blue })
	hl(0, "@tag.delimiter", { fg = c.gray })
	hl(0, "@text", { fg = c.fg })
	hl(0, "@text.strong", { bold = true })
	hl(0, "@text.emphasis", { italic = true })
	hl(0, "@text.underline", { underline = true })
	hl(0, "@text.strike", { strikethrough = true })
	hl(0, "@text.title", { fg = c.blue, bold = true })
	hl(0, "@text.literal", { fg = c.orange })
	hl(0, "@text.uri", { fg = c.orange, underline = true })
	hl(0, "@text.reference", { fg = c.light_blue })
	hl(0, "@text.todo", { fg = c.yellow_orange, bold = true })
	hl(0, "@attribute", { fg = c.yellow })
	hl(0, "@attribute.builtin", { fg = c.blue_green })
	hl(0, "@property", { fg = c.light_blue })
	hl(0, "@field", { fg = c.light_blue })

	-- LSP Semantic Tokens
	hl(0, "@lsp.type.class", { fg = c.blue_green })
	hl(0, "@lsp.type.decorator", { fg = c.yellow })
	hl(0, "@lsp.type.enum", { fg = c.blue_green })
	hl(0, "@lsp.type.enumMember", { fg = c.blue })
	hl(0, "@lsp.type.function", { fg = c.yellow })
	hl(0, "@lsp.type.interface", { fg = c.blue_green })
	hl(0, "@lsp.type.macro", { fg = c.pink })
	hl(0, "@lsp.type.method", { fg = c.yellow })
	hl(0, "@lsp.type.namespace", { fg = c.blue_green })
	hl(0, "@lsp.type.parameter", { fg = c.light_blue })
	hl(0, "@lsp.type.property", { fg = c.light_blue })
	hl(0, "@lsp.type.struct", { fg = c.blue_green })
	hl(0, "@lsp.type.type", { fg = c.blue_green })
	hl(0, "@lsp.type.typeParameter", { fg = c.blue_green })
	hl(0, "@lsp.type.variable", { fg = c.light_blue })

	-- LSP
	hl(0, "LspReferenceText", { bg = c.selection })
	hl(0, "LspReferenceRead", { bg = c.selection })
	hl(0, "LspReferenceWrite", { bg = c.selection })
	hl(0, "LspSignatureActiveParameter", { fg = c.yellow_orange })
	hl(0, "LspInlayHint", { fg = c.line_nr, bg = "NONE", italic = true })

	-- NvimTree
	hl(0, "NvimTreeNormal", { fg = c.fg, bg = "NONE" })
	hl(0, "NvimTreeNormalNC", { fg = c.fg, bg = "NONE" })
	hl(0, "NvimTreeRootFolder", { fg = c.pink })
	hl(0, "NvimTreeFolderName", { fg = c.blue })
	hl(0, "NvimTreeFolderIcon", { fg = c.blue })
	hl(0, "NvimTreeOpenedFolderName", { fg = c.blue })
	hl(0, "NvimTreeEmptyFolderName", { fg = c.gray })
	hl(0, "NvimTreeIndentMarker", { fg = c.line_nr_dim })
	hl(0, "NvimTreeGitDirty", { fg = c.yellow })
	hl(0, "NvimTreeGitNew", { fg = "#81b88b" })
	hl(0, "NvimTreeGitDeleted", { fg = "#c74e39" })
	hl(0, "NvimTreeGitIgnored", { fg = "#8c8c8c" })
	hl(0, "NvimTreeGitRenamed", { fg = "#73c991" })
	hl(0, "NvimTreeGitStaged", { fg = "#e2c08d" })
	hl(0, "NvimTreeGitMerge", { fg = "#73c991" })
	hl(0, "NvimTreeSpecialFile", { fg = c.yellow_orange })
	hl(0, "NvimTreeImageFile", { fg = c.fg })
	hl(0, "NvimTreeSymlink", { fg = c.blue_green })
	hl(0, "NvimTreeWinSeparator", { fg = c.dim, bg = "NONE" })
	hl(0, "NvimTreeCursorLine", { bg = "#03395e" })

	-- GitSigns
	hl(0, "GitSignsAdd", { fg = c.diff_add })
	hl(0, "GitSignsChange", { fg = c.diff_change })
	hl(0, "GitSignsDelete", { fg = c.diff_delete })

	-- Diffview (VSCode-style diff colors with transparency)
	hl(0, "DiffviewFilePanelTitle", { fg = c.blue, bold = true })
	hl(0, "DiffviewFilePanelCounter", { fg = c.pink })
	hl(0, "DiffviewFilePanelRootPath", { fg = c.line_nr_dim }) -- hide root path
	hl(0, "DiffviewFolderName", { fg = c.blue, bold = true })
	hl(0, "DiffviewFolderSign", { fg = c.pink })
	hl(0, "DiffviewFilePanelFileName", { fg = c.fg })
	hl(0, "DiffviewDiffAdd", { bg = c.diff_add_line, blend = 50 })
	hl(0, "DiffviewDiffAddAsDelete", { bg = c.diff_delete_line, blend = 50 })
	hl(0, "DiffviewDiffDelete", { fg = "#5a3535", bg = c.diff_delete_line, blend = 50 })
	hl(0, "DiffviewDiffAddText", { bg = c.diff_add_text, blend = 30 })
	hl(0, "DiffviewDiffDeleteText", { bg = c.diff_delete_text, blend = 30 })
	hl(0, "DiffviewStatusAdded", { fg = c.diff_add })
	hl(0, "DiffviewStatusModified", { fg = c.diff_change })
	hl(0, "DiffviewStatusDeleted", { fg = c.diff_delete })
	hl(0, "DiffviewStatusRenamed", { fg = "#73c991" })

	-- Telescope/FZF
	hl(0, "TelescopeNormal", { fg = c.fg, bg = "NONE" })
	hl(0, "TelescopeBorder", { fg = c.dim, bg = "NONE" })
	hl(0, "TelescopePromptNormal", { fg = c.fg, bg = "NONE" })
	hl(0, "TelescopePromptBorder", { fg = c.dim, bg = "NONE" })
	hl(0, "TelescopeResultsNormal", { fg = c.fg, bg = "NONE" })
	hl(0, "TelescopeResultsBorder", { fg = c.dim, bg = "NONE" })
	hl(0, "TelescopePreviewNormal", { fg = c.fg, bg = "NONE" })
	hl(0, "TelescopePreviewBorder", { fg = c.dim, bg = "NONE" })
	hl(0, "TelescopeMatching", { fg = c.yellow })
	hl(0, "TelescopeSelection", { bg = c.selection })

	-- Match paren
	hl(0, "MatchParen", { bg = c.selection, bold = true })

	-- WinBar
	hl(0, "WinBar", { fg = c.fg, bg = "NONE", bold = true })
	hl(0, "WinBarNC", { fg = c.gray, bg = "NONE" })

	-- Markdown headings
	hl(0, "@markup.heading.1", { fg = c.blue, bold = true })
	hl(0, "@markup.heading.2", { fg = c.orange, bold = true })
	hl(0, "@markup.heading.3", { fg = c.yellow, bold = true })
	hl(0, "@markup.heading.4", { fg = c.green, bold = true })
	hl(0, "@markup.heading.5", { fg = c.pink, bold = true })
	hl(0, "@markup.heading.6", { fg = c.blue_green, bold = true })
	hl(0, "@markup.raw", { fg = c.orange })
	hl(0, "@markup.link.label", { fg = c.light_blue, underline = true })
	hl(0, "@markup.link.url", { fg = c.fg, underline = true })
	hl(0, "@markup.list.checked", { link = "Todo" })
	hl(0, "@markup.list.unchecked", { link = "Todo" })

	-- Indent guides (indent-blankline)
	hl(0, "IblIndent", { fg = "#2a2a2a" })
	hl(0, "IblScope", { fg = c.dim })

	-- Rainbow delimiters
	hl(0, "RainbowDelimiterRed", { fg = c.red })
	hl(0, "RainbowDelimiterYellow", { fg = c.yellow })
	hl(0, "RainbowDelimiterBlue", { fg = c.blue })
	hl(0, "RainbowDelimiterOrange", { fg = c.orange })
	hl(0, "RainbowDelimiterGreen", { fg = c.green })
	hl(0, "RainbowDelimiterViolet", { fg = c.pink })
	hl(0, "RainbowDelimiterCyan", { fg = c.blue_green })

	-- Copilot
	hl(0, "CopilotSuggestion", { fg = c.gray })

	-- Which-key
	hl(0, "WhichKey", { fg = c.pink })
	hl(0, "WhichKeyGroup", { fg = c.blue })
	hl(0, "WhichKeyDesc", { fg = c.fg })
	hl(0, "WhichKeySeparator", { fg = c.gray })
	hl(0, "WhichKeyBorder", { fg = c.dim })

	-- LSP control flow keywords
	hl(0, "@lsp.typemod.keyword.controlFlow", { fg = c.pink })

	-- Misc
	hl(0, "Directory", { fg = c.blue })
	hl(0, "Title", { fg = c.blue, bold = true })
	hl(0, "Question", { fg = c.blue })
	hl(0, "MoreMsg", { fg = c.blue })
	hl(0, "ModeMsg", { fg = c.fg })
	hl(0, "WarningMsg", { fg = c.yellow })
	hl(0, "ErrorMsg", { fg = c.red })
	hl(0, "WildMenu", { fg = c.fg, bg = c.selection })
	hl(0, "Conceal", { fg = c.gray })
	hl(0, "SpellBad", { undercurl = true, sp = c.red })
	hl(0, "SpellCap", { undercurl = true, sp = c.blue })
	hl(0, "SpellLocal", { undercurl = true, sp = c.blue_green })
	hl(0, "SpellRare", { undercurl = true, sp = c.pink })
end

function M.setup()
	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	vim.o.termguicolors = true
	vim.g.colors_name = "vscode"

	set_highlights()

	-- Terminal colors
	vim.g.terminal_color_0 = "#1E1E1E"
	vim.g.terminal_color_1 = c.red
	vim.g.terminal_color_2 = c.green
	vim.g.terminal_color_3 = c.yellow
	vim.g.terminal_color_4 = c.blue
	vim.g.terminal_color_5 = c.pink
	vim.g.terminal_color_6 = c.blue_green
	vim.g.terminal_color_7 = c.fg
	vim.g.terminal_color_8 = c.gray
	vim.g.terminal_color_9 = c.light_red
	vim.g.terminal_color_10 = "#81b88b"
	vim.g.terminal_color_11 = c.yellow_orange
	vim.g.terminal_color_12 = c.light_blue
	vim.g.terminal_color_13 = c.pink
	vim.g.terminal_color_14 = c.blue_green
	vim.g.terminal_color_15 = c.white
end

return M

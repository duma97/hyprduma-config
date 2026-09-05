vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.g.colors_name = "ultraviolet"
vim.o.background = "dark"
vim.o.termguicolors = true

local c = {
	bg0 = "#0B0C10",
	bg1 = "#0E0E11",
	bg2 = "#111115",
	bg3 = "#1B1B1F",
	bg4 = "#222226",
	bg5 = "#393940",

	fg0 = "#F2F4F8",
	fg1 = "#DCD8ED",
	fg2 = "#9AA1AB",
	fg3 = "#3A3A3A",

	blue = "#6F78FF",
	purple = "#C58FFF",
	green = "#08BD8A",
	red = "#FF6FAE",
	yellow = "#E297DB",
	cyan = "#B3BCEF",
	orange = "#AF9CFF",
	olive = "#08BDBA",
	op = "#DFDFE0",

	none = "NONE",
}

local hl = function(g, o) vim.api.nvim_set_hl(0, g, o) end

hl("Normal", { fg = c.fg0, bg = c.bg2 })
hl("NormalNC", { fg = c.fg0, bg = c.bg2 })
hl("NormalFloat", { fg = c.fg0, bg = c.bg1 })
hl("FloatBorder", { fg = c.bg5, bg = c.bg1 })
hl("FloatTitle", { fg = c.blue, bg = c.bg1, bold = true })
hl("Cursor", { fg = c.bg2, bg = c.fg0 })
hl("CursorLine", { bg = c.bg3 })
hl("CursorColumn", { bg = c.bg3 })
hl("CursorLineNr", { fg = c.fg0, bold = true })
hl("LineNr", { fg = c.fg2 })
hl("SignColumn", { bg = c.none })
hl("ColorColumn", { bg = c.bg3 })
hl("VertSplit", { fg = c.bg4 })
hl("WinSeparator", { fg = c.bg4 })
hl("Folded", { fg = c.fg2, bg = c.bg3 })
hl("FoldColumn", { fg = c.fg2, bg = c.none })
hl("MatchParen", { fg = c.purple, bold = true, underline = true })
hl("NonText", { fg = c.fg3 })
hl("Whitespace", { fg = c.fg3 })
hl("SpecialKey", { fg = c.fg3 })
hl("EndOfBuffer", { fg = c.bg2 })
hl("Conceal", { fg = c.fg2 })

hl("Visual", { bg = c.bg5 })
hl("VisualNOS", { bg = c.bg5 })
hl("Search", { fg = c.bg2, bg = c.purple })
hl("IncSearch", { fg = c.bg2, bg = c.blue })
hl("CurSearch", { fg = c.bg2, bg = c.blue })

hl("StatusLine", { fg = c.fg0, bg = c.bg2 })
hl("StatusLineNC", { fg = c.fg2, bg = c.bg2 })
hl("TabLine", { fg = c.fg2, bg = c.bg2 })
hl("TabLineFill", { bg = c.bg2 })
hl("TabLineSel", { fg = c.fg0, bg = c.bg3 })
hl("WildMenu", { fg = c.bg2, bg = c.blue })
hl("ModeMsg", { fg = c.fg0, bold = true })
hl("MoreMsg", { fg = c.blue, bold = true })
hl("Question", { fg = c.blue })
hl("Title", { fg = c.blue, bold = true })

hl("Pmenu", { fg = c.fg1, bg = c.bg1 })
hl("PmenuSel", { fg = c.fg0, bg = c.bg4 })
hl("PmenuSbar", { bg = c.bg3 })
hl("PmenuThumb", { bg = c.bg5 })
hl("PmenuKind", { fg = c.purple, bg = c.bg1 })
hl("PmenuKindSel", { fg = c.purple, bg = c.bg4 })

hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.yellow, bold = true })

hl("DiffAdd", { bg = "#0F2A20" })
hl("DiffChange", { bg = "#1F1A2A" })
hl("DiffDelete", { fg = c.red, bg = "#2A0F1A" })
hl("DiffText", { bg = "#2A2240" })

hl("SpellBad", { undercurl = true, sp = c.red })
hl("SpellCap", { undercurl = true, sp = c.yellow })
hl("SpellLocal", { undercurl = true, sp = c.cyan })
hl("SpellRare", { undercurl = true, sp = c.purple })

hl("Comment", { fg = c.fg2, italic = true })
hl("Constant", { fg = c.purple })
hl("String", { fg = c.olive })
hl("Character", { fg = c.olive })
hl("Number", { fg = c.green })
hl("Boolean", { fg = c.green })
hl("Float", { fg = c.green })
hl("Identifier", { fg = c.fg1 })
hl("Function", { fg = c.orange })
hl("Statement", { fg = c.blue })
hl("Conditional", { fg = c.blue })
hl("Repeat", { fg = c.blue })
hl("Label", { fg = c.blue })
hl("Operator", { fg = c.op })
hl("Keyword", { fg = c.blue })
hl("Exception", { fg = c.red })
hl("PreProc", { fg = c.purple })
hl("Include", { fg = c.blue })
hl("Define", { fg = c.blue })
hl("Macro", { fg = c.purple })
hl("PreCondit", { fg = c.blue })
hl("Type", { fg = c.purple })
hl("StorageClass", { fg = c.blue })
hl("Structure", { fg = c.purple })
hl("Typedef", { fg = c.purple })
hl("Special", { fg = c.cyan })
hl("SpecialChar", { fg = c.orange })
hl("Tag", { fg = c.purple })
hl("Delimiter", { fg = c.op })
hl("SpecialComment", { fg = c.fg2, italic = true })
hl("Debug", { fg = c.red })
hl("Underlined", { fg = c.blue, underline = true })
hl("Error", { fg = c.red, bold = true })
hl("Todo", { fg = c.bg2, bg = c.yellow, bold = true })

hl("@variable", { fg = c.fg1 })
hl("@variable.builtin", { fg = c.red })
hl("@variable.parameter", { fg = c.cyan, italic = true })
hl("@variable.member", { fg = c.fg1 })
hl("@constant", { fg = c.purple })
hl("@constant.builtin", { fg = c.purple })
hl("@constant.macro", { fg = c.purple })
hl("@string", { fg = c.olive })
hl("@string.escape", { fg = c.orange })
hl("@string.special", { fg = c.orange })
hl("@string.regexp", { fg = c.cyan })
hl("@character", { fg = c.olive })
hl("@number", { fg = c.green })
hl("@boolean", { fg = c.green })
hl("@float", { fg = c.green })
hl("@function", { fg = c.orange })
hl("@function.builtin", { fg = c.orange })
hl("@function.macro", { fg = c.purple })
hl("@function.method", { fg = c.orange })
hl("@function.call", { fg = c.orange })
hl("@method", { fg = c.orange })
hl("@method.call", { fg = c.orange })
hl("@keyword", { fg = c.blue })
hl("@keyword.function", { fg = c.blue })
hl("@keyword.operator", { fg = c.blue })
hl("@keyword.return", { fg = c.blue })
hl("@keyword.import", { fg = c.blue })
hl("@conditional", { fg = c.blue })
hl("@repeat", { fg = c.blue })
hl("@label", { fg = c.blue })
hl("@operator", { fg = c.op })
hl("@exception", { fg = c.red })
hl("@type", { fg = c.purple })
hl("@type.builtin", { fg = c.purple })
hl("@type.definition", { fg = c.purple })
hl("@constructor", { fg = c.purple })
hl("@namespace", { fg = c.cyan })
hl("@module", { fg = c.cyan })
hl("@include", { fg = c.blue })
hl("@property", { fg = c.fg1 })
hl("@attribute", { fg = c.purple })
hl("@field", { fg = c.fg1 })
hl("@comment", { fg = c.fg2, italic = true })
hl("@comment.documentation", { fg = c.fg2, italic = true })
hl("@punctuation.bracket", { fg = c.op })
hl("@punctuation.delimiter", { fg = c.op })
hl("@punctuation.special", { fg = c.orange })
hl("@tag", { fg = c.purple })
hl("@tag.attribute", { fg = c.cyan, italic = true })
hl("@tag.delimiter", { fg = c.fg2 })

hl("@markup.heading", { fg = c.blue, bold = true })
hl("@markup.heading.1", { fg = c.blue, bold = true })
hl("@markup.heading.2", { fg = c.purple, bold = true })
hl("@markup.heading.3", { fg = c.orange, bold = true })
hl("@markup.heading.4", { fg = c.green, bold = true })
hl("@markup.strong", { fg = c.fg0, bold = true })
hl("@markup.italic", { fg = c.fg0, italic = true })
hl("@markup.link", { fg = c.blue, underline = true })
hl("@markup.link.url", { fg = c.cyan, underline = true })
hl("@markup.raw", { fg = c.olive })
hl("@markup.list", { fg = c.purple })
hl("@markup.quote", { fg = c.fg2, italic = true })

hl("@lsp.type.class", { fg = c.purple })
hl("@lsp.type.decorator", { fg = c.purple })
hl("@lsp.type.enum", { fg = c.purple })
hl("@lsp.type.enumMember", { fg = c.purple })
hl("@lsp.type.function", { fg = c.orange })
hl("@lsp.type.interface", { fg = c.purple })
hl("@lsp.type.macro", { fg = c.purple })
hl("@lsp.type.method", { fg = c.orange })
hl("@lsp.type.namespace", { fg = c.cyan })
hl("@lsp.type.parameter", { fg = c.cyan, italic = true })
hl("@lsp.type.property", { fg = c.fg1 })
hl("@lsp.type.struct", { fg = c.purple })
hl("@lsp.type.type", { fg = c.purple })
hl("@lsp.type.typeParameter", { fg = c.purple })
hl("@lsp.type.variable", { fg = c.fg1 })
hl("@lsp.type.keyword", { fg = c.blue })

hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.cyan })
hl("DiagnosticHint", { fg = c.olive })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.cyan })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.olive })
hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.none })
hl("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.none })
hl("DiagnosticVirtualTextInfo", { fg = c.cyan, bg = c.none })
hl("DiagnosticVirtualTextHint", { fg = c.olive, bg = c.none })

hl("GitSignsAdd", { fg = c.green })
hl("GitSignsChange", { fg = c.blue })
hl("GitSignsDelete", { fg = c.red })
hl("DiffAdded", { fg = c.green })
hl("DiffChanged", { fg = c.blue })
hl("DiffRemoved", { fg = c.red })

hl("TelescopeBorder", { fg = c.bg5, bg = c.bg1 })
hl("TelescopePromptBorder", { fg = c.bg5, bg = c.bg1 })
hl("TelescopeResultsBorder", { fg = c.bg5, bg = c.bg1 })
hl("TelescopePreviewBorder", { fg = c.bg5, bg = c.bg1 })
hl("TelescopeNormal", { fg = c.fg0, bg = c.bg1 })
hl("TelescopePromptNormal", { fg = c.fg0, bg = c.bg1 })
hl("TelescopeSelection", { fg = c.fg0, bg = c.bg4 })
hl("TelescopeSelectionCaret", { fg = c.purple, bg = c.bg4 })
hl("TelescopeMatching", { fg = c.purple, bold = true })
hl("TelescopeTitle", { fg = c.bg2, bg = c.blue, bold = true })

hl("NeoTreeNormal", { fg = c.fg0, bg = c.bg1 })
hl("NeoTreeNormalNC", { fg = c.fg0, bg = c.bg1 })
hl("NeoTreeDirectoryName", { fg = c.fg1 })
hl("NeoTreeDirectoryIcon", { fg = c.blue })
hl("NeoTreeFileName", { fg = c.fg0 })
hl("NeoTreeFileIcon", { fg = c.fg2 })
hl("NeoTreeRootName", { fg = c.purple, bold = true })
hl("NeoTreeIndentMarker", { fg = c.bg4 })
hl("NeoTreeGitModified", { fg = c.yellow })
hl("NeoTreeGitAdded", { fg = c.green })
hl("NeoTreeGitDeleted", { fg = c.red })
hl("NeoTreeGitUntracked", { fg = c.purple })

hl("WhichKey", { fg = c.purple, bold = true })
hl("WhichKeyGroup", { fg = c.blue })
hl("WhichKeyDesc", { fg = c.fg0 })
hl("WhichKeySeparator", { fg = c.fg2 })
hl("WhichKeyFloat", { bg = c.bg1 })
hl("WhichKeyBorder", { fg = c.bg5, bg = c.bg1 })

hl("IndentBlanklineChar", { fg = c.bg3 })
hl("IndentBlanklineContextChar", { fg = c.bg5 })
hl("IblIndent", { fg = c.bg3 })
hl("IblScope", { fg = c.bg5 })

hl("NoicePopup", { fg = c.fg0, bg = c.bg1 })
hl("NoiceCmdlinePopup", { fg = c.fg0, bg = c.bg1 })
hl("NoiceCmdlinePopupBorder", { fg = c.bg5, bg = c.bg1 })
hl("NotifyBackground", { bg = c.bg1 })
hl("NotifyERRORBorder", { fg = c.red })
hl("NotifyWARNBorder", { fg = c.yellow })
hl("NotifyINFOBorder", { fg = c.cyan })
hl("NotifyDEBUGBorder", { fg = c.fg2 })
hl("NotifyTRACEBorder", { fg = c.purple })

hl("MasonNormal", { fg = c.fg0, bg = c.bg1 })
hl("MasonHeader", { fg = c.bg2, bg = c.purple, bold = true })
hl("MasonHighlight", { fg = c.purple })
hl("MasonHighlightBlock", { fg = c.bg2, bg = c.purple })

hl("CmpItemAbbrMatch", { fg = c.purple, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = c.purple, bold = true })
hl("CmpItemKindFunction", { fg = c.orange })
hl("CmpItemKindMethod", { fg = c.orange })
hl("CmpItemKindKeyword", { fg = c.blue })
hl("CmpItemKindVariable", { fg = c.fg1 })
hl("CmpItemKindClass", { fg = c.purple })
hl("CmpItemKindInterface", { fg = c.purple })
hl("CmpItemKindText", { fg = c.olive })

hl("DashboardHeader", { fg = c.purple })
hl("DashboardCenter", { fg = c.blue })
hl("DashboardFooter", { fg = c.fg2, italic = true })
hl("AlphaHeader", { fg = c.purple })
hl("AlphaButtons", { fg = c.fg0 })
hl("AlphaShortcut", { fg = c.blue })
hl("AlphaFooter", { fg = c.fg2, italic = true })

vim.g.terminal_color_0 = c.bg2
vim.g.terminal_color_1 = c.red
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_5 = c.purple
vim.g.terminal_color_6 = c.cyan
vim.g.terminal_color_7 = c.fg0
vim.g.terminal_color_8 = c.bg5
vim.g.terminal_color_9 = c.red
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.yellow
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_13 = c.purple
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.fg0

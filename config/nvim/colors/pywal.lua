vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "pywal"

local cache_root = vim.env.XDG_CACHE_HOME
if not cache_root or cache_root == "" then cache_root = vim.fn.expand("~/.cache") end
local wal_colors_path = cache_root .. "/wal/colors.json"

local function get_wal_colors()
    local colors_file = wal_colors_path
    local file = io.open(colors_file, "r")
    if not file then
        vim.notify("Pywal colors not found at " .. colors_file, vim.log.levels.WARN)
        return nil
    end

    local content = file:read("*all")
    file:close()

    local ok, decoded = pcall(vim.json.decode, content)
    if not ok or type(decoded) ~= "table" or type(decoded.special) ~= "table" or type(decoded.colors) ~= "table" then
        vim.notify("Failed to parse pywal colors.json", vim.log.levels.ERROR)
        return nil
    end

    return {
        bg = decoded.special.background,
        fg = decoded.special.foreground,
        cursor = decoded.special.cursor,
        color0 = decoded.colors.color0,
        color1 = decoded.colors.color1,
        color2 = decoded.colors.color2,
        color3 = decoded.colors.color3,
        color4 = decoded.colors.color4,
        color5 = decoded.colors.color5,
        color6 = decoded.colors.color6,
        color7 = decoded.colors.color7,
        color8 = decoded.colors.color8,
        color9 = decoded.colors.color9,
        color10 = decoded.colors.color10,
        color11 = decoded.colors.color11,
        color12 = decoded.colors.color12,
        color13 = decoded.colors.color13,
        color14 = decoded.colors.color14,
        color15 = decoded.colors.color15,
    }
end

local c = get_wal_colors()
if not c then
    return
end

local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.color0 })
hl("FloatBorder", { fg = c.color8, bg = c.color0 })
hl("ColorColumn", { bg = c.color0 })
hl("Cursor", { fg = c.bg, bg = c.cursor })
hl("CursorLine", { bg = c.color0 })
hl("CursorColumn", { bg = c.color0 })
hl("LineNr", { fg = c.color8 })
hl("CursorLineNr", { fg = c.color4, bold = true })
hl("SignColumn", { fg = c.color8, bg = c.bg })
hl("VertSplit", { fg = c.color8, bg = c.bg })
hl("WinSeparator", { fg = c.color8, bg = c.bg })
hl("Folded", { fg = c.color8, bg = c.color0 })
hl("FoldColumn", { fg = c.color8, bg = c.bg })
hl("NonText", { fg = c.color8 })
hl("SpecialKey", { fg = c.color8 })
hl("Whitespace", { fg = c.color8 })
hl("EndOfBuffer", { fg = c.bg })

hl("Search", { fg = c.bg, bg = c.color3 })
hl("IncSearch", { fg = c.bg, bg = c.color4 })
hl("CurSearch", { fg = c.bg, bg = c.color4 })
hl("Substitute", { fg = c.bg, bg = c.color1 })

hl("Visual", { bg = c.color8 })
hl("VisualNOS", { bg = c.color8 })

hl("ErrorMsg", { fg = c.color1, bold = true })
hl("WarningMsg", { fg = c.color3, bold = true })
hl("ModeMsg", { fg = c.fg, bold = true })
hl("MoreMsg", { fg = c.color2 })
hl("Question", { fg = c.color4 })

hl("StatusLine", { fg = c.fg, bg = c.color0 })
hl("StatusLineNC", { fg = c.color8, bg = c.color0 })
hl("TabLine", { fg = c.color8, bg = c.color0 })
hl("TabLineFill", { bg = c.color0 })
hl("TabLineSel", { fg = c.fg, bg = c.bg, bold = true })
hl("WinBar", { fg = c.fg, bg = c.bg })
hl("WinBarNC", { fg = c.color8, bg = c.bg })

hl("Pmenu", { fg = c.fg, bg = c.color0 })
hl("PmenuSel", { fg = c.bg, bg = c.color4 })
hl("PmenuSbar", { bg = c.color0 })
hl("PmenuThumb", { bg = c.color8 })

hl("DiffAdd", { fg = c.color2, bg = c.bg })
hl("DiffChange", { fg = c.color3, bg = c.bg })
hl("DiffDelete", { fg = c.color1, bg = c.bg })
hl("DiffText", { fg = c.color4, bg = c.bg })

hl("SpellBad", { sp = c.color1, undercurl = true })
hl("SpellCap", { sp = c.color3, undercurl = true })
hl("SpellLocal", { sp = c.color4, undercurl = true })
hl("SpellRare", { sp = c.color5, undercurl = true })

hl("Comment", { fg = c.color8, italic = true })
hl("Constant", { fg = c.color5 })
hl("String", { fg = c.color2 })
hl("Character", { fg = c.color2 })
hl("Number", { fg = c.color5 })
hl("Boolean", { fg = c.color5 })
hl("Float", { fg = c.color5 })

hl("Identifier", { fg = c.color4 })
hl("Function", { fg = c.color4 })

hl("Statement", { fg = c.color1 })
hl("Conditional", { fg = c.color1 })
hl("Repeat", { fg = c.color1 })
hl("Label", { fg = c.color1 })
hl("Operator", { fg = c.fg })
hl("Keyword", { fg = c.color1 })
hl("Exception", { fg = c.color1 })

hl("PreProc", { fg = c.color3 })
hl("Include", { fg = c.color1 })
hl("Define", { fg = c.color5 })
hl("Macro", { fg = c.color5 })
hl("PreCondit", { fg = c.color3 })

hl("Type", { fg = c.color3 })
hl("StorageClass", { fg = c.color3 })
hl("Structure", { fg = c.color3 })
hl("Typedef", { fg = c.color3 })

hl("Special", { fg = c.color6 })
hl("SpecialChar", { fg = c.color6 })
hl("Tag", { fg = c.color4 })
hl("Delimiter", { fg = c.fg })
hl("SpecialComment", { fg = c.color8 })
hl("Debug", { fg = c.color1 })

hl("Underlined", { fg = c.color4, underline = true })
hl("Ignore", { fg = c.color8 })
hl("Error", { fg = c.color1, bold = true })
hl("Todo", { fg = c.bg, bg = c.color3, bold = true })

hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.color1 })
hl("@variable.parameter", { fg = c.color6 })
hl("@variable.member", { fg = c.color4 })
hl("@constant", { fg = c.color5 })
hl("@constant.builtin", { fg = c.color5 })
hl("@constant.macro", { fg = c.color5 })
hl("@module", { fg = c.color3 })
hl("@label", { fg = c.color1 })
hl("@string", { fg = c.color2 })
hl("@string.escape", { fg = c.color6 })
hl("@string.special", { fg = c.color6 })
hl("@character", { fg = c.color2 })
hl("@number", { fg = c.color5 })
hl("@boolean", { fg = c.color5 })
hl("@float", { fg = c.color5 })
hl("@function", { fg = c.color4 })
hl("@function.builtin", { fg = c.color4 })
hl("@function.macro", { fg = c.color5 })
hl("@function.method", { fg = c.color4 })
hl("@constructor", { fg = c.color3 })
hl("@keyword", { fg = c.color1 })
hl("@keyword.function", { fg = c.color1 })
hl("@keyword.operator", { fg = c.color1 })
hl("@keyword.return", { fg = c.color1 })
hl("@operator", { fg = c.fg })
hl("@punctuation.delimiter", { fg = c.fg })
hl("@punctuation.bracket", { fg = c.fg })
hl("@punctuation.special", { fg = c.color6 })
hl("@type", { fg = c.color3 })
hl("@type.builtin", { fg = c.color3 })
hl("@attribute", { fg = c.color4 })
hl("@property", { fg = c.color4 })
hl("@comment", { fg = c.color8, italic = true })
hl("@tag", { fg = c.color1 })
hl("@tag.attribute", { fg = c.color4 })
hl("@tag.delimiter", { fg = c.fg })

hl("@lsp.type.class", { fg = c.color3 })
hl("@lsp.type.decorator", { fg = c.color4 })
hl("@lsp.type.enum", { fg = c.color3 })
hl("@lsp.type.enumMember", { fg = c.color5 })
hl("@lsp.type.function", { fg = c.color4 })
hl("@lsp.type.interface", { fg = c.color3 })
hl("@lsp.type.macro", { fg = c.color5 })
hl("@lsp.type.method", { fg = c.color4 })
hl("@lsp.type.namespace", { fg = c.color3 })
hl("@lsp.type.parameter", { fg = c.color6 })
hl("@lsp.type.property", { fg = c.color4 })
hl("@lsp.type.struct", { fg = c.color3 })
hl("@lsp.type.type", { fg = c.color3 })
hl("@lsp.type.variable", { fg = c.fg })

hl("DiagnosticError", { fg = c.color1 })
hl("DiagnosticWarn", { fg = c.color3 })
hl("DiagnosticInfo", { fg = c.color4 })
hl("DiagnosticHint", { fg = c.color6 })
hl("DiagnosticUnderlineError", { sp = c.color1, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.color3, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.color4, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.color6, undercurl = true })

hl("GitSignsAdd", { fg = c.color2 })
hl("GitSignsChange", { fg = c.color3 })
hl("GitSignsDelete", { fg = c.color1 })

hl("TelescopeNormal", { fg = c.fg, bg = c.bg })
hl("TelescopeBorder", { fg = c.color8 })
hl("TelescopePromptNormal", { fg = c.fg, bg = c.color0 })
hl("TelescopePromptBorder", { fg = c.color8, bg = c.color0 })
hl("TelescopePromptTitle", { fg = c.bg, bg = c.color4 })
hl("TelescopePreviewTitle", { fg = c.bg, bg = c.color2 })
hl("TelescopeResultsTitle", { fg = c.bg, bg = c.color5 })
hl("TelescopeSelection", { fg = c.fg, bg = c.color0 })
hl("TelescopeMatching", { fg = c.color4, bold = true })

hl("NvimTreeNormal", { fg = c.fg, bg = c.bg })
hl("NvimTreeFolderIcon", { fg = c.color4 })
hl("NvimTreeFolderName", { fg = c.color4 })
hl("NvimTreeOpenedFolderName", { fg = c.color4 })
hl("NvimTreeRootFolder", { fg = c.color1 })
hl("NvimTreeGitDirty", { fg = c.color3 })
hl("NvimTreeGitNew", { fg = c.color2 })
hl("NvimTreeGitDeleted", { fg = c.color1 })

hl("NeoTreeNormal", { fg = c.fg, bg = c.bg })
hl("NeoTreeDirectoryIcon", { fg = c.color4 })
hl("NeoTreeDirectoryName", { fg = c.color4 })
hl("NeoTreeRootName", { fg = c.color1, bold = true })
hl("NeoTreeGitModified", { fg = c.color3 })
hl("NeoTreeGitAdded", { fg = c.color2 })
hl("NeoTreeGitDeleted", { fg = c.color1 })

hl("IndentBlanklineChar", { fg = c.color0 })
hl("IblIndent", { fg = c.color0 })
hl("IblScope", { fg = c.color8 })

hl("WhichKey", { fg = c.color4 })
hl("WhichKeyGroup", { fg = c.color5 })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeparator", { fg = c.color8 })

hl("LazyButton", { fg = c.fg, bg = c.color0 })
hl("LazyButtonActive", { fg = c.bg, bg = c.color4 })
hl("LazyH1", { fg = c.bg, bg = c.color4, bold = true })
hl("LazySpecial", { fg = c.color4 })

hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrMatch", { fg = c.color4, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = c.color4, bold = true })
hl("CmpItemKind", { fg = c.color5 })
hl("CmpItemMenu", { fg = c.color8 })

hl("NotifyERRORBorder", { fg = c.color1 })
hl("NotifyWARNBorder", { fg = c.color3 })
hl("NotifyINFOBorder", { fg = c.color4 })
hl("NotifyDEBUGBorder", { fg = c.color8 })
hl("NotifyTRACEBorder", { fg = c.color5 })
hl("NotifyERRORIcon", { fg = c.color1 })
hl("NotifyWARNIcon", { fg = c.color3 })
hl("NotifyINFOIcon", { fg = c.color4 })
hl("NotifyDEBUGIcon", { fg = c.color8 })
hl("NotifyTRACEIcon", { fg = c.color5 })
hl("NotifyERRORTitle", { fg = c.color1 })
hl("NotifyWARNTitle", { fg = c.color3 })
hl("NotifyINFOTitle", { fg = c.color4 })
hl("NotifyDEBUGTitle", { fg = c.color8 })
hl("NotifyTRACETitle", { fg = c.color5 })

hl("MatchParen", { fg = c.color4, bg = c.color8, bold = true })

hl("Directory", { fg = c.color4 })
hl("Title", { fg = c.color4, bold = true })
hl("Conceal", { fg = c.color8 })

local group = vim.api.nvim_create_augroup("PywalAutoReload", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = group,
    callback = function()
        if vim.g.colors_name == "pywal" then

            local stat = vim.loop.fs_stat(wal_colors_path)
            if stat then
                local mtime = tostring(stat.mtime.sec) .. ":" .. tostring(stat.mtime.nsec)
                if vim.g.pywal_last_mtime and mtime ~= vim.g.pywal_last_mtime then
                    vim.cmd("colorscheme pywal")
                end
                vim.g.pywal_last_mtime = mtime
            end
        end
    end,
})

local stat = vim.loop.fs_stat(wal_colors_path)
if stat then
    vim.g.pywal_last_mtime = tostring(stat.mtime.sec) .. ":" .. tostring(stat.mtime.nsec)
end

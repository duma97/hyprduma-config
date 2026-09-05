---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function cmp(p)
  return {
    -- menu text
    CmpItemAbbr = { fg = p.fg0 },
    CmpItemAbbrDeprecated = { fg = p.fg3, strikethrough = true },
    CmpItemAbbrMatch = { fg = p.accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = p.accent, bold = true },
    CmpItemMenu = { fg = p.fg2 },

    -- kind icons (matches blink.lua mapping)
    CmpItemKind = { fg = p.fg2 },
    CmpItemKindText = { fg = p.fg1 },
    CmpItemKindMethod = { fg = p.accent },
    CmpItemKindFunction = { fg = p.accent },
    CmpItemKindConstructor = { fg = p.blue },
    CmpItemKindField = { fg = p.fg0 },
    CmpItemKindVariable = { fg = p.fg0 },
    CmpItemKindClass = { fg = p.blue },
    CmpItemKindInterface = { fg = p.blue },
    CmpItemKindModule = { fg = p.blue },
    CmpItemKindProperty = { fg = p.fg0 },
    CmpItemKindUnit = { fg = p.purple },
    CmpItemKindValue = { fg = p.purple },
    CmpItemKindEnum = { fg = p.blue },
    CmpItemKindKeyword = { fg = p.accent2 },
    CmpItemKindSnippet = { fg = p.green },
    CmpItemKindColor = { fg = p.purple },
    CmpItemKindFile = { fg = p.blue },
    CmpItemKindReference = { fg = p.blue },
    CmpItemKindFolder = { fg = p.blue },
    CmpItemKindEnumMember = { fg = p.purple },
    CmpItemKindConstant = { fg = p.purple },
    CmpItemKindStruct = { fg = p.blue },
    CmpItemKindEvent = { fg = p.accent2 },
    CmpItemKindOperator = { fg = p.fg1 },
    CmpItemKindTypeParameter = { fg = p.blue },
  }
end

return cmp

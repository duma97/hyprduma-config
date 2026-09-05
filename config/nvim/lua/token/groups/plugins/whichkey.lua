---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function whichkey(p)
  return {
    WhichKey = { fg = p.accent },
    WhichKeySeparator = { fg = p.fg3 },
    WhichKeyGroup = { fg = p.blue },
    WhichKeyDesc = { fg = p.fg1 },
    WhichKeyNormal = { fg = p.fg0, bg = p.bg0 },
    WhichKeyBorder = { fg = p.fg3, bg = p.bg0 },
    WhichKeyTitle = { fg = p.accent, bg = p.bg0, bold = true },
    WhichKeyValue = { fg = p.fg2 },
    WhichKeyIcon = { fg = p.blue },
    WhichKeyIconAzure = { fg = p.cyan },
    WhichKeyIconBlue = { fg = p.blue },
    WhichKeyIconCyan = { fg = p.cyan },
    WhichKeyIconGreen = { fg = p.green },
    WhichKeyIconGrey = { fg = p.fg2 },
    WhichKeyIconOrange = { fg = p.accent },
    WhichKeyIconPurple = { fg = p.purple },
    WhichKeyIconRed = { fg = p.red },
    WhichKeyIconYellow = { fg = p.yellow },
  }
end

return whichkey

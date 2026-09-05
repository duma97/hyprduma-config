---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function trouble(p)
  return {
    TroubleNormal = { fg = p.fg0, bg = p.bg1 },
    TroubleNormalNC = { fg = p.fg0, bg = p.bg1 },
    TroubleCount = { fg = p.accent, bold = true },
    TroubleIconError = { fg = p.red },
    TroubleIconWarning = { fg = p.yellow },
    TroubleIconInformation = { fg = p.blue },
    TroubleIconHint = { fg = p.cyan },
    TroubleIconOther = { fg = p.fg2 },
    TroubleIconDirectory = { fg = p.blue },
    TroubleIconFile = { fg = p.fg0 },
    TroubleText = { fg = p.fg0 },
    TroubleTextError = { fg = p.red },
    TroubleTextWarning = { fg = p.yellow },
    TroubleTextInformation = { fg = p.blue },
    TroubleTextHint = { fg = p.cyan },
    TroubleCode = { fg = p.fg2 },
    TroubleSource = { fg = p.fg2 },
    TroublePos = { fg = p.fg3 },
    TroubleIndent = { fg = p.fg3 },
    TroubleIndentFoldOpen = { fg = p.accent },
    TroubleIndentFoldClosed = { fg = p.fg3 },
    TroubleIndentWs = { fg = p.fg3 },
    TroubleIndentTop = { fg = p.fg3 },
    TroubleIndentMiddle = { fg = p.fg3 },
    TroubleIndentLast = { fg = p.fg3 },
    TroubleAncestry = { fg = p.fg3 },
    TroubleBasename = { fg = p.fg0, bold = true },
    TroubleDirectory = { fg = p.blue },
    TroubleDirname = { fg = p.blue },
    TroubleFilename = { fg = p.fg0 },
    TroublePreview = { bg = p.bg4 },
  }
end

return trouble

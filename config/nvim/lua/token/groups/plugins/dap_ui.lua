---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function dap_ui(p)
  return {
    -- window
    DapUINormal = { fg = p.fg0, bg = p.bg1 },
    DapUIEndofBuffer = { fg = p.bg1 },
    DapUIFloatNormal = { link = 'NormalFloat' },
    DapUIFloatBorder = { link = 'FloatBorder' },

    -- variables and scoping
    DapUIVariable = { fg = p.fg0 },
    DapUIType = { fg = p.blue },
    DapUIValue = { fg = p.purple },
    DapUIModifiedValue = { fg = p.accent, bold = true },
    DapUIScope = { fg = p.accent, bold = true },
    DapUIDecoration = { fg = p.fg3 },

    -- threads and frames
    DapUIThread = { fg = p.green },
    DapUIStoppedThread = { fg = p.accent, bold = true },
    DapUIFrameName = { fg = p.fg0 },
    DapUISource = { fg = p.blue, italic = true },
    DapUILineNumber = { link = 'LineNr' },
    DapUICurrentFrameName = { link = 'DapUIBreakpointsCurrentLine' },

    -- breakpoints
    DapUIBreakpointsPath = { fg = p.blue },
    DapUIBreakpointsInfo = { fg = p.blue },
    DapUIBreakpointsCurrentLine = { fg = p.accent, bold = true },
    DapUIBreakpointsLine = { link = 'DapUILineNumber' },
    DapUIBreakpointsDisabledLine = { fg = p.fg3 },

    -- watches
    DapUIWatchesEmpty = { fg = p.fg3 },
    DapUIWatchesValue = { fg = p.purple },
    DapUIWatchesError = { fg = p.red },

    -- controls
    DapUIPlayPause = { fg = p.green },
    DapUIRestart = { fg = p.green },
    DapUIStepOver = { fg = p.blue },
    DapUIStepInto = { fg = p.blue },
    DapUIStepBack = { fg = p.blue },
    DapUIStepOut = { fg = p.blue },
    DapUIStop = { fg = p.red },
    DapUIUnavailable = { fg = p.fg3 },
    DapUIWinSelect = { fg = p.accent, bold = true },
  }
end

return dap_ui

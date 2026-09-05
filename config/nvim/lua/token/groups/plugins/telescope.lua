---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function telescope(p)
  return {
    -- main window
    TelescopeNormal = { fg = p.fg0, bg = p.bg1 },
    TelescopeBorder = { fg = p.fg3, bg = p.bg1 },
    TelescopeTitle = { fg = p.accent, bg = p.bg1, bold = true },

    -- prompt
    TelescopePromptNormal = { fg = p.fg0, bg = p.bg1 },
    TelescopePromptBorder = { fg = p.fg3, bg = p.bg1 },
    TelescopePromptTitle = { fg = p.accent2, bg = p.bg1, bold = true },
    TelescopePromptPrefix = { fg = p.accent },
    TelescopePromptCounter = { fg = p.fg3 },

    -- results
    TelescopeResultsNormal = { link = 'TelescopeNormal' },
    TelescopeResultsBorder = { link = 'TelescopeBorder' },
    TelescopeResultsTitle = { link = 'TelescopeTitle' },

    -- preview
    TelescopePreviewNormal = { fg = p.fg0, bg = p.bg0 },
    TelescopePreviewBorder = { fg = p.fg3, bg = p.bg0 },
    TelescopePreviewTitle = { fg = p.accent2, bg = p.bg0, bold = true },

    -- selection and matching
    TelescopeSelection = { bg = p.sel, bold = true },
    TelescopeSelectionCaret = { fg = p.accent, bg = p.sel },
    TelescopeMultiSelection = { fg = p.accent2, bg = p.sel },
    TelescopeMultiIcon = { fg = p.accent2 },
    TelescopeMatching = { fg = p.accent, bold = true },

    -- preview highlights
    TelescopePreviewLine = { bg = p.bg5 },
    TelescopePreviewMatch = { link = 'Search' },

    -- git diff in results
    TelescopeResultsDiffAdd = { fg = p.green },
    TelescopeResultsDiffChange = { fg = p.yellow },
    TelescopeResultsDiffDelete = { fg = p.red },
    TelescopeResultsDiffUntracked = { fg = p.fg3 },
  }
end

return telescope

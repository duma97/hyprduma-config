---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function neo_tree(p)
  return {
    -- window
    NeoTreeNormal = { fg = p.fg0, bg = p.bg1 },
    NeoTreeNormalNC = { fg = p.fg0, bg = p.bg1 },
    NeoTreeEndOfBuffer = { fg = p.bg1 },
    NeoTreeWinSeparator = { fg = p.bg4, bg = p.bg1 },
    NeoTreeCursorLine = { bg = p.bg4 },
    NeoTreeSignColumn = { link = 'NeoTreeNormal' },
    NeoTreeStatusLine = { link = 'StatusLineNC' },
    NeoTreeStatusLineNC = { link = 'StatusLineNC' },

    -- files and directories
    NeoTreeRootName = { fg = p.accent, bold = true },
    NeoTreeDirectoryName = { fg = p.blue },
    NeoTreeDirectoryIcon = { fg = p.blue },
    NeoTreeFileName = { fg = p.fg0 },
    NeoTreeFileIcon = { fg = p.fg0 },
    NeoTreeSymbolicLinkTarget = { fg = p.purple, italic = true },
    NeoTreeIndentMarker = { fg = p.fg3 },
    NeoTreeExpander = { fg = p.fg3 },
    NeoTreeDotfile = { fg = p.fg3 },
    NeoTreeHiddenByName = { fg = p.fg3 },
    NeoTreeDimText = { fg = p.fg3 },
    NeoTreeFilterTerm = { fg = p.accent, bold = true },

    -- float window
    NeoTreeFloatBorder = { fg = p.fg3, bg = p.bg0 },
    NeoTreeFloatTitle = { fg = p.accent, bg = p.bg0, bold = true },
    NeoTreeTitleBar = { fg = p.bg3, bg = p.accent, bold = true },

    -- git status
    NeoTreeGitAdded = { fg = p.green },
    NeoTreeGitConflict = { fg = p.accent },
    NeoTreeGitDeleted = { fg = p.red },
    NeoTreeGitIgnored = { fg = p.fg3 },
    NeoTreeGitModified = { fg = p.yellow },
    NeoTreeGitRenamed = { fg = p.purple },
    NeoTreeGitStaged = { fg = p.green },
    NeoTreeGitUnstaged = { fg = p.yellow },
    NeoTreeGitUntracked = { fg = p.fg3 },

    -- modified indicator
    NeoTreeModified = { fg = p.yellow },
  }
end

return neo_tree

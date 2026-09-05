---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function treesitter_context(p)
  return {
    TreesitterContext = { bg = p.bg2 },
    TreesitterContextLineNumber = { fg = p.fg3, bg = p.bg2 },
    TreesitterContextBottom = { underline = true, sp = p.fg3 },
    TreesitterContextLineNumberBottom = { underline = true, sp = p.fg3 },
    TreesitterContextSeparator = { fg = p.fg3 },
  }
end

return treesitter_context

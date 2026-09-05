---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function ibl(p)
  return {
    IblIndent = { fg = p.indent },
    IblScope = { fg = p.indent_active },
    IblWhitespace = { fg = p.indent },
  }
end

return ibl

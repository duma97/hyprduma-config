---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function hlchunk(p)
  return {
    HLChunk1 = { fg = p.indent_active },
    HLChunk2 = { fg = p.red },
    HLIndent1 = { fg = p.indent },
    HLLineNum1 = { fg = p.indent_active },
    HLBlank1 = { fg = p.indent },
  }
end

return hlchunk

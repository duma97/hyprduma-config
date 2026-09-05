---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function claudecode(p)
  return {
    ClaudeCodeDiffAdd = { bg = p.diff_add },
    ClaudeCodeDiffDelete = { bg = p.diff_del },
    ClaudeCodeDiffChange = { bg = p.diff_change },
    ClaudeCodeDiffText = { bg = p.diff_text },
  }
end

return claudecode

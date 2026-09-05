---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function flash(p)
  return {
    FlashBackdrop = { fg = p.fg3 },
    FlashMatch = { fg = p.fg0, bg = p.match },
    FlashCurrent = { fg = p.bg3, bg = p.accent2 },
    FlashLabel = { fg = p.bg3, bg = p.accent, bold = true },
    FlashCursor = { link = 'Cursor' },
    FlashPrompt = { link = 'MsgArea' },
    FlashPromptIcon = { fg = p.accent },
  }
end

return flash

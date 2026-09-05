---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function todo_comments(p)
  return {
    -- FIX/FIXME/BUG
    TodoBgFIX = { fg = p.bg3, bg = p.red, bold = true },
    TodoFgFIX = { fg = p.red },
    TodoSignFIX = { fg = p.red },

    -- TODO
    TodoBgTODO = { fg = p.bg3, bg = p.blue, bold = true },
    TodoFgTODO = { fg = p.blue },
    TodoSignTODO = { fg = p.blue },

    -- HACK
    TodoBgHACK = { fg = p.bg3, bg = p.yellow, bold = true },
    TodoFgHACK = { fg = p.yellow },
    TodoSignHACK = { fg = p.yellow },

    -- WARN/WARNING/XXX
    TodoBgWARN = { fg = p.bg3, bg = p.yellow, bold = true },
    TodoFgWARN = { fg = p.yellow },
    TodoSignWARN = { fg = p.yellow },

    -- PERF/OPTIM/OPTIMIZE
    TodoBgPERF = { fg = p.bg3, bg = p.fg1, bold = true },
    TodoFgPERF = { fg = p.fg1 },
    TodoSignPERF = { fg = p.fg1 },

    -- NOTE/INFO
    TodoBgNOTE = { fg = p.bg3, bg = p.cyan, bold = true },
    TodoFgNOTE = { fg = p.cyan },
    TodoSignNOTE = { fg = p.cyan },

    -- TEST/TESTING/PASSED/FAILED
    TodoBgTEST = { fg = p.bg3, bg = p.purple, bold = true },
    TodoFgTEST = { fg = p.purple },
    TodoSignTEST = { fg = p.purple },
  }
end

return todo_comments

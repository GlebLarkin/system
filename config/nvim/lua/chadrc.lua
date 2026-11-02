-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "mountain",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },

  -- readable diagnostics: coloured curly underlines
  hl_add = {
    DiagnosticUnderlineError = { undercurl = true, sp = "#e06c75" },
    DiagnosticUnderlineWarn = { undercurl = true, sp = "#e5c07b" },
    DiagnosticUnderlineInfo = { undercurl = true, sp = "#61afef" },
    DiagnosticUnderlineHint = { undercurl = true, sp = "#98c379" },
  },
}

M.ui = {
  statusline = { theme = "minimal", separator_style = "round" },
  telescope = { style = "bordered" },
}

M.nvdash = { load_on_startup = true }

return M

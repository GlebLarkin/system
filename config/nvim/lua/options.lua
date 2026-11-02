require "nvchad.options"

local o = vim.o
o.cursorlineopt = "both"
o.relativenumber = true
o.scrolloff = 8
o.undofile = true
o.signcolumn = "yes"
o.termguicolors = true

-- C / C++: 4 spaces, ruler at 100
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.wo.colorcolumn = "100"
  end,
})

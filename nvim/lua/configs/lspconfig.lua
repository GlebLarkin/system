--require("nvchad.configs.lspconfig").defaults()

--local servers = { "html", "cssls" }
--vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 

--local lspconfig = require("lspconfig")

-- Python LSP
--lspconfig.pyright.setup {}

-- C++ (опционально)
--lspconfig.clangd.setup {}

-- Можно будет сюда добавить и другие языки
--vim.diagnostic.config({
--  virtual_text = false,  -- отключает текст прямо в коде (по желанию)
--  float = {
--    focusable = false,
--    style = "minimal",
--   border = "rounded",
--    source = "always",   -- показывать, откуда сообщение (pyright и т.д.)
--    header = "",
--    prefix = "",
--    width = 80,          -- максимальная ширина popup-окна с ошибкой
--  },
--})
--vim.o.updatetime = 250 -- задержка перед CursorHold
--vim.cmd([[
--  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus = false })
--]])
--require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

local lspconfig = require("lspconfig")

-- 📌 Общее поведение диагностик
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    width = 80,
  },
})

vim.o.updatetime = 250

-- ❌ Удаляем автопоказ ошибок
-- УДАЛИ или закомментируй эту строку:
-- vim.cmd([[ autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus = false }) ]])

-- ✅ on_attach с биндингом на ","
local on_attach = function(client, bufnr)
  vim.keymap.set("n", ",", function()
    vim.diagnostic.open_float(nil, { focus = false })
  end, { buffer = bufnr, desc = "Show diagnostics" })
end

-- Python LSP
lspconfig.pyright.setup {
  on_attach = on_attach,
}

-- C++ (опционально)
lspconfig.clangd.setup {
  on_attach = on_attach,
}

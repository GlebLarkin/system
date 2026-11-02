local nv = require "nvchad.configs.lspconfig"
nv.defaults()

-- diagnostics are drawn by tiny-inline-diagnostic.nvim, so native virtual text stays off
vim.diagnostic.config {
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
  float = {
    focusable = false,
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
    width = 80,
  },
}

vim.o.updatetime = 250

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style=llvm",
    "--pch-storage=memory",
  },
  capabilities = vim.tbl_deep_extend("force", nv.capabilities, { offsetEncoding = { "utf-16" } }),
  init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
})

vim.lsp.enable { "clangd", "pyright", "html", "cssls" }

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = "LSP " .. desc })
    end

    map(",", function()
      vim.diagnostic.open_float(nil, { focus = false })
    end, "line diagnostics")
    map("<leader>ca", vim.lsp.buf.code_action, "code action")
    map("gr", vim.lsp.buf.references, "references")
    map("gi", vim.lsp.buf.implementation, "implementation")

    if client and client.supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      map("<leader>ch", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }, { bufnr = buf })
      end, "toggle inlay hints")
    end

    if client and client.name == "clangd" then
      map("<leader>cs", "<cmd>LspClangdSwitchSourceHeader<cr>", "switch source/header")
    end
  end,
})

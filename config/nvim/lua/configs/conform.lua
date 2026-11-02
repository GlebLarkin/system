local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  formatters = {
    -- use the project's .clang-format, fall back to LLVM style when there is none
    ["clang-format"] = { prepend_args = { "--fallback-style=LLVM" } },
  },

  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "c" or ft == "cpp" then
      return { timeout_ms = 1500, lsp_format = "fallback" }
    end
  end,
}

return options

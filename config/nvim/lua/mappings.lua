require "nvchad.mappings"
--- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "<leader>o", "o<Esc>", { desc = "Empty line below" })
map("n", "<leader>O", "O<Esc>", { desc = "Empty line above" })
map("n", "d", '"_d', { desc = "Delete without yank" })
map("n", "x", '"_x', { desc = "Delete char without yank" })
map("n", "ge", "$", { desc = "Go to end of line" })
map("n", "ff", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find text in current buffer" })

-- C / C++ build & run in a bottom terminal
local function compile_and_run()
  local ft = vim.bo.filetype
  if ft ~= "c" and ft ~= "cpp" then
    return vim.notify("Not a C/C++ file", vim.log.levels.WARN)
  end
  vim.cmd "write"
  local src = vim.fn.shellescape(vim.fn.expand "%:p")
  local out = vim.fn.shellescape("/tmp/" .. vim.fn.expand "%:t:r")
  local cc = ft == "c" and "gcc -std=c17" or "g++ -std=c++20"
  require("nvchad.term").runner {
    pos = "sp",
    id = "runner",
    cmd = string.format("%s -g -Wall -Wextra %s -o %s && %s", cc, src, out, out),
  }
end

map("n", "<leader>cr", compile_and_run, { desc = "C/C++ compile & run current file" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

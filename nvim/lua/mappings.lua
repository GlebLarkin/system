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

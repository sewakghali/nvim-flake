-- lua/plugins/comment.lua
return {
	"numToStr/Comment.nvim",
	lazy = false, -- load immediately
	config = function()
		local comment = require("Comment")
		comment.setup()

		local api = require("Comment.api")
		local map = vim.keymap.set

		-- Normal mode: toggle current line
		map("n", "<C-_>", api.toggle.linewise.current, { desc = "Toggle comment line" })

		-- Visual mode: toggle selection
		map("x", "<C-_>", function()
			api.toggle.linewise(vim.fn.visualmode())
		end, { desc = "Toggle comment selection" })

		-- Insert mode: toggle current line and return to insert mode
		map("i", "<C-_>", function()
			-- leave insert mode
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			-- toggle comment
			api.toggle.linewise.current()
			-- re-enter insert mode
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", true)
		end, { desc = "Toggle comment in insert mode" })
	end,
}

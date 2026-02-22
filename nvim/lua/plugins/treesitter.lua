return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
	  autotag = { enable = true },
			ensure_installed = {
				"lua",
				"tsx",
				"javascript",
				"typescript",
				"c",
				"css",
				"html",
				"typescript",
				"svelte",
				"dart",
				"json",
				"jsonc",
				"java",
				"kotlin",
				"swift",
				"markdown",
				"markdown_inline",
				"nginx",
				"dockerfile",
				"json",
				"yaml",
				"bash",
				"dockerfile",
				"gitignore",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
		})
	end,
}

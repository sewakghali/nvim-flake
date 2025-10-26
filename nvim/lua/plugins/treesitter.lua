return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			ensure_installed = {
				lua,
				javascript,
				typescript,
				c,
				css,
				html,
				typescript,
				svelte,
				dart,
				json,
				jsonc,
				java,
				kotlin,
				swift,
				markdown,
				markdown_inline,
				nginx,
				dockerfile,
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local plugins = {

	{ import = "plugins" },
	-- 1. nvim-lspconfig: Includes all setup logic now
	{
		"neovim/nvim-lspconfig",
		lazy = false, -- Ensure it loads immediately
		config = function()
			-- All post-load configuration now runs here!

			-- Load the file that enables LSP and sets keymaps
			require("config.lsp_setup")

			-- If you have other shared LSP configurations, they can also go here.
		end,
	},
}

-- The actual setup call
require("lazy").setup(plugins, {
	-- Add any global lazy options here
})

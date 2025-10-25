return {
	-- The core command (Nix flake ensures this is on $PATH)
	cmd = { "lua-language-server" },
	-- Server-specific settings
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
				-- Include the base nvim config path from your flake for better completion
				library = {
					vim.env.XDG_CONFIG_HOME .. "/nvim",
				},
			},
			diagnostics = {
				globals = { "vim", "require" },
			},
			runtime = {
				version = "LuaJIT",
			},
			telemetry = {
				enable = false,
			},
			format = {
				enable = true,
				defaultGuidingStars = false,
			},
		},
	},
}

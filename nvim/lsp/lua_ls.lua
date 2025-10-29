return {
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
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

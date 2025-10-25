return {
  cmd = { "deno", "lsp" },
  filetypes = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "markdown",
  },
  root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc", "mod.ts", "deps.ts"),
  settings = {
    deno = {
      enable = true,
      unstable = true,
    },
  },
}

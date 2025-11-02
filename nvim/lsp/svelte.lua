return {
  name = "svelte",
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_dir = require("lspconfig.util").root_pattern(
    "package-lock.json",
    "svelte.config.js",
    "svelte.config.cjs",
    "yarn.lock",
    "pnpm-lock.yaml",
    "bun.lockb",
    "bun.lock",
    "deno.lock",
    ".git"
  ),
}

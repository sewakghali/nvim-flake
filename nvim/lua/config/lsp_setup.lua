vim.keymap.set("n", "gd", "<Nop>")

vim.lsp.enable("lua_ls")
vim.lsp.enable("denols")
vim.lsp.enable("nil")

-- enable autocompletion from language servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Explicitly remove the deprecated global handler override for safety,
-- though it's better to ensure it's not set in the first place.
vim.lsp.handlers["textDocument/definition"] = nil

-- ----------------------------------------------------
-- LSP UTILITIES & WINDOW SETTINGS
-- ----------------------------------------------------

-- Global Handler: Customize how diagnostics pop up when the cursor moves
vim.lsp.handlers["textDocument/hover"] = vim.lsp.handlers.signature_help
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.handlers.signature_help

-- ----------------------------------------------------
-- ATTACHMENT LOGIC (on_attach)
-- ----------------------------------------------------

local on_attach = function(client, bufnr)
  local lsp_group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = false })
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
  vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts) -- Use Telescope for better results

  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

  -- Show Code Actions (e.g., Fix, Extract, Refactor)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

  -- Display buffer diagnostics in a floating window
  vim.keymap.set("n", "<leader>d", require("telescope.builtin").diagnostics, opts)

  -- Jump to next/prev diagnostic in the buffer
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- Auto-Formatting on Save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = lsp_group,
      buffer = bufnr,
      callback = function()
        -- Synchronous format on save
        vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 1500 })
      end,
    })
  end
end

-- ----------------------------------------------------
-- LSPATTACH AUTOCOMMAND
-- ----------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspClientAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    on_attach(client, args.buf)
  end,
})

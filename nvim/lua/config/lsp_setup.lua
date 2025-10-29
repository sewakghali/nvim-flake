vim.keymap.set("n", "gd", "<Nop>")

vim.lsp.enable("lua_ls")
vim.lsp.enable("denols")
vim.lsp.enable("gopls")
vim.lsp.enable("nil")
vim.lsp.enable("postgrestools")
vim.lsp.enable("html")
vim.lsp.enable("svelte")

-- enable autocompletion from language servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- ----------------------------------------------------
-- LSP UTILITIES & WINDOW SETTINGS
-- ----------------------------------------------------

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- ----------------------------------------------------
-- ATTACHMENT LOGIC (on_attach)
-- ----------------------------------------------------

local on_attach = function(client, bufnr)
	local lsp_group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = false })
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
	vim.keymap.set("n", "gdi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gdt", vim.lsp.buf.type_definition, opts)

	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, opts)
	vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)
	vim.keymap.set("n", "<leader>d", require("telescope.builtin").diagnostics, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

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

if client.server_capabilities.documentHighlightProvider then
	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		group = lsp_group,
		buffer = bufnr,
		callback = vim.lsp.buf.document_highlight,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = lsp_group,
		buffer = bufnr,
		callback = vim.lsp.buf.clear_references,
	})
end

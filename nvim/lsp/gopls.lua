return {
	cmd = { "gopls" },
	filetypes = {
		"go",
	},
	root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".vim/", ".git/", ".hg/"),
}

-- extra config that will be imported into nixvim

-- lsp for solidity
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

configs.solidity = {
	default_config = {
		cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
		filetypes = { "solidity" },
		root_dir = lspconfig.util.find_git_ancestor,
		single_file_support = false,
	},
}

lspconfig.solidity.setup({})

-- remove cmp for markdown
require("cmp").setup({
	enabled = function()
		return vim.bo.filetype ~= "markdown"
	end,
})

-- Enable linebreak by default
vim.opt.linebreak = true

-- Disable wrap by default
vim.opt.wrap = false

-- Autocommand to enable wrap for markdown and text files
vim.api.nvim_create_augroup("WrapMarkdownText", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "WrapMarkdownText",
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
	end,
})

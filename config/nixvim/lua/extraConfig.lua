-- extra config that will be imported into nixvim

vim.lsp.set_log_level("debug")

-- lsp for solidity
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

configs.solidity = {
	default_config = {
		cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
		-- experimenting with increaing the max-old-space-size
		-- cmd = {
		-- 	"node",
		-- 	"--max-old-space-size=8912",
		-- 	"/home/jordan/.npm-packages/lib/node_modules/@nomicfoundation/solidity-language-server",
		-- 	"--stdio",
		-- },
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

-- nvim scrollbar
require("scrollbar").setup()

-- lualine
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		section_separators = "",
		component_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { { "filename", path = 1 } }, -- Full path from repo root
		lualine_x = {
			{ "diagnostics", sources = { "nvim_diagnostic" }, sections = { "error", "warn" } }, -- LSP diagnostics
			"encoding",
			"filetype",
		},
		lualine_y = { "progress" }, -- Shows % through the file
		lualine_z = { "location" }, -- Current line and column
	},
})

-- bufferline
require("bufferline").setup({
	options = {
		show_close_icon = false,
		show_buffer_close_icons = false,
		show_tab_indicators = false,
		always_show_bufferline = false,
	},
})

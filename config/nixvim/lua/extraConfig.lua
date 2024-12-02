-- extra config that will be imported into nixvim

-- lsp for solidity
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

configs.solidity = {
	default_config = {
		cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
		--		experimenting with increaing the max-old-space-size
		-- cmd = {
		-- 	"node",
		-- 	"--max-old-space-size=8912",
		-- 	"/home/jordan/.npm-packages/lib/node_modules/@nomicfoundation/solidity-language-server",
		-- 	"--stdio",
		-- },
		-- cmd = {
		-- 	"/home/jordan/Documents/dev/crypto/investigations/hardhat-vscode/server/out/index.js",
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

-- dont open a blank tree automatically
require("auto-session").setup({
	post_restore_cmds = {
		function()
			local nvim_tree_api = require("nvim-tree.api")
			nvim_tree_api.tree.open() -- Open Nvim Tree
			nvim_tree_api.tree.reload() -- Reload the tree
		end,
	},
})

-- when wrapped use visual lines for movement
vim.api.nvim_create_augroup("WrapCursorMovement", {})

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "wrap",
	group = "WrapCursorMovement",
	callback = function()
		vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })
	end,
})

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "nowrap",
	group = "WrapCursorMovement",
	callback = function()
		vim.api.nvim_set_keymap("n", "j", "j", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "k", "k", { noremap = true, silent = true })
	end,
})

local function show_priority_diagnostic_or_hover()
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = pos[1] - 1
	local col = pos[2]

	-- Get diagnostics for the current line
	local diagnostics = vim.diagnostic.get(0, { lnum = line })

	if #diagnostics > 0 then
		-- Sort diagnostics by severity (lower severity number is higher priority)
		table.sort(diagnostics, function(a, b)
			return a.severity < b.severity
		end)

		-- Find the highest-priority diagnostic covering the cursor
		for _, diag in ipairs(diagnostics) do
			if col >= diag.col and col <= diag.end_col then
				-- Sanitize multiline diagnostic messages
				local sanitized_message = vim.split(diag.message or "", "\n", { plain = true })

				-- Open a float with diagnostic information, retaining colors
				vim.diagnostic.open_float(0, {
					scope = "cursor",
					focusable = false,
					header = "",
					prefix = "",
					source = false,
					severity_sort = true,
					close_events = { "CursorMoved", "InsertEnter" },
				})
				return
			end
		end
	end

	-- Fallback to LSP hover if no relevant diagnostics are found
	vim.lsp.buf.hover()
end

vim.keymap.set("n", "<leader>i", show_priority_diagnostic_or_hover, { noremap = true, silent = true })

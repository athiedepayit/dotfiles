local kmap = vim.keymap.set
local o = vim.opt
local g = vim.g

o.ignorecase = true    -- search case insensitive
o.smartcase = true     -- search matters if capital letter
o.inccommand = "split" -- "for incsearch while sub

g.netrw_banner = 0
g.netrw_browse_split = 4
g.netrw_liststyle = 3
g.netrw_winsize = -28
g.netrw_browsex_viewer = "firefox-esr"

o.number = true
o.backspace = "2"
--o.guicursor = "i:block"
o.splitright = true
o.splitbelow = true
--o.softtabstop = 4
--o.shiftwidth = 4
o.colorcolumn = '80'
o.smartindent = true
o.linebreak = true
o.laststatus = 0
o.updatetime = 250
g.wrap = true

g.t_Co = 256
g.mapleader = " "
kmap("n", "<leader>pv", vim.cmd.Ex)
kmap("n", "<C-w>N", ":vnew<CR>")
kmap("n", "<C-h>", "<C-w>h")
kmap("n", "<C-j>", "<C-w>j")
kmap("n", "<C-k>", "<C-w>k")
kmap("n", "<C-l>", "<C-w>l")

kmap("n", "bn", ":bnext<CR>")
kmap("n", "bN", ":bprevious<CR>")
kmap("n", "bx", ":bdelete<CR>")

kmap("n", "<Esc>", "<cmd>nohlsearch<CR>")

kmap("n", "<F2>", ":NERDTreeToggle<CR>")
kmap("n", "<F6>", ":setlocal spell! spelllang=en_us<CR>")
kmap("n", "<F5>", ":so ~/.config/nvim/init.lua<CR>")
kmap("n", "<Leader>r", ":so ~/.config/nvim/init.lua<CR>")
kmap("n", "<Leader>h", ":nohlsearch<CR>")
kmap("t", "<ESC>", "<C-w>:q!<CR>")
kmap("i", "jj", "<esc>")
kmap("n", "bD", ":set background=dark<cr>")
kmap("n", "bL", ":set background=light<cr>")
kmap("n", "<leader>D", ":Gdiff<cr>")
kmap("n", "<leader>B", ":G blame<cr>")
kmap("n", "<leader>gf", ":edit %:h/<cfile><CR>")
kmap("n", "<leader>n", ":set nonumber<CR>")
kmap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
kmap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- insert date
kmap("n", "<leader>dt", ':r! date "+\\%Y-\\%m-\\%d" <CR>')
kmap("n", "<leader>tt", ':r! date "+\\%H:\\%M:\\%S" <CR>')

-- remember last place
local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_clear_autocmds({ group = lastplace })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = lastplace,
	pattern = { "*" },
	desc = "remember last cursor place",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- plugins with vim-plug
vim.cmd([[
" Install vim-plug if not found
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
  Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'echasnovski/mini.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'preservim/nerdtree'
Plug 'folke/trouble.nvim'
Plug 'Exafunction/codeium.vim'
"Completions
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
call plug#end()
]])

g.codeium_filetypes = {
	markdown = false,
	text = false
}
kmap("n", '<leader>ai', ':CodeiumToggle<cr>')

local lspconfig = require("lspconfig")

require('mini.statusline').setup({
	use_icons = false,
})
require('mini.tabline').setup({
	show_icons = false,
})
-- transparent background
vim.cmd("highlight Normal guibg=none")
vim.cmd("highlight NonText guibg=none")
vim.cmd("highlight Normal ctermbg=none")
vim.cmd("highlight NonText ctermbg=none")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<leader>pg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>b", builtin.buffers, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
	builtin.grep_string({ search = vim.fn.input("grep > ") })
end)

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = { "lua", "bash", "rust", "c", "go", "markdown", "python", "ruby" },
	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

-- lsps
require 'lspconfig'.gopls.setup {}
require 'lspconfig'.rust_analyzer.setup {}
require 'lspconfig'.lua_ls.setup {}

-- format on save
vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]

--require("lsp_lines").setup()
require("trouble").setup()
vim.keymap.set("n", "<leader>xx", ":Trouble diagnostics toggle<CR>")

-----------------
-- COMPLETIONS --
-----------------
-- most of this is just copied from the README of nvim-cmp
local cmp = require 'cmp'
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			--vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
			vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
		end,
	},
	window = {
		--completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-h>'] = cmp.mapping.select_next_item(),
		['<C-y>'] = cmp.mapping.select_prev_item(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = 'buffer' },
	})
})
filetypes = { 'txt', 'html', 'text', 'gemtext', 'markdown' }
for _, type in ipairs(filetypes) do
	cmp.setup.filetype(type, { enabled = false })
end

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
--[[
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})
]] --

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
--[[
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})
]] --

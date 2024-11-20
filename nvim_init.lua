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
o.softtabstop = 4
o.shiftwidth = 4
o.smartindent = true
o.linebreak = true
--o.laststatus = 0
--o.showtabline = 2
o.updatetime = 250
g.wrap = true
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevel = 99

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

kmap("n", "<F2>", ":NvimTreeToggle<CR>")
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

-- remember last place
local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_clear_autocmds({ group = lastplace })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = lastplace,
	pattern = { "*" },
	desc = "remember last cursor place", -- {{{
	callback = function()             -- }}}
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
Plug 'junegunn/goyo.vim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'echasnovski/mini.nvim'
Plug 'Exafunction/codeium.vim'
Plug 'rose-pine/neovim'
"LSPs and Tree Sitter stuff
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
call plug#end()
]])

local lspconfig = require("lspconfig")

require('mini.statusline').setup({ use_icons = false })
require('mini.tabline').setup()

-- disable codeium by default
g.codeium_enabled = false
kmap("n", '<leader>ai', ':CodeiumToggle<cr>')
g.codeium_filetypes = {
	markdown = false,
	text = false
}

-- status line with bufferline
-- g.bufferline_echo = 0
-- g.bufferline_active_buffer_left = '*'
-- g.bufferline_active_buffer_right = ''
-- vim.cmd [[autocmd VimEnter * let &statusline='%{bufferline#refresh_status()}'.bufferline#get_status_string() ]]
-- vim.cmd [[autocmd VimEnter * let &tabline='%{bufferline#refresh_status()}'.bufferline#get_status_string() ]]

-- strip trailing spaces
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		pcall(function() vim.cmd [[%s/\s\+$//e]] end)
		vim.fn.setpos(".", save_cursor)
	end,
})
vim.cmd [[ match ExtraWhitespace /\s\+$/ ]]
vim.cmd [[ highlight ExtraWhiteSpace ctermbg=gray guibg=gray ]]

-- transparent background
--vim.cmd("highlight Normal guibg=none")
--vim.cmd("highlight NonText guibg=none")
--vim.cmd("highlight Normal ctermbg=none")
--vim.cmd("highlight NonText ctermbg=none")

require('nvim-tree').setup()

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

-- force set filetypes
local function set_filetype(pattern, filetype)
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = pattern,
		command = "set filetype=" .. filetype,
	})
end
set_filetype({ "Dockerfile" }, "dockerfile")
set_filetype({ "DOCKERFILE" }, "dockerfile")
set_filetype({ "CONTAINERFILE" }, "dockerfile")

-- lsps
require 'lspconfig'.gopls.setup {}
require 'lspconfig'.rust_analyzer.setup {}
require 'lspconfig'.lua_ls.setup {}
require 'lspconfig'.terraform_lsp.setup {}
--powershell lsp conflicts with powershell plugin
require 'lspconfig'.powershell_es.setup {
	bundle_path = '/Users/athiede/.local/share/pslsp',
}

-- format on save
vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]

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
-- disable autoccompletion for writing
filetypes = { 'txt', 'html', 'text', 'gemtext', 'markdown' }
for _, type in ipairs(filetypes) do
	cmp.setup.filetype(type, { enabled = false })
end

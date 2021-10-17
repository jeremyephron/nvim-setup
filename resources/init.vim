" Neovim configuration settings

" Autoinstall vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Specify plugin directory
call plug#begin()

  " Builtin language server
  Plug 'neovim/nvim-lspconfig'

  " Completion for the builtin language server
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/nvim-cmp'

  " Treesitter
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-refactor'

  " Python completions
  Plug 'ncm2/ncm2-jedi'

  " Telescope
  "   run `:help telescope` for more information
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  " NerdTree (file browser)
  "   run `:help nerdtree` for more information
  Plug 'preservim/nerdtree'

  " TagBar (browse tags of source code files)
  "   run `:help tagbar` for more information
  Plug 'preservim/tagbar'

  " Fugitive (git wrapper for vim)
  "   run `:help fugitive` for more information
  Plug 'tpope/vim-fugitive'

  " NNN (NNN file picker)
  "   run `:help nnn` for more information
  Plug 'mcchrish/nnn.vim'

  " FZF
  "   run `:help fzf` for more information
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " Markdown
  Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}

" Initialize the plugin system
call plug#end()

filetype plugin indent on
syntax on

colorscheme Monokai

set exrc secure " source local init.vim file if present

set number " line numbers

set mouse=a " enable mouse control
if &term =~ '^screen'
  " tmux knows the extended mouse mode
  set ttymouse=xterm2
endif

set backspace=indent,eol,start " allow backspace to go over anything.

set tabstop=4     " how many columns a tab counts for
set softtabstop=4 " how many spaces should be treated as a tab
set shiftwidth=4  " how far an indent is with reindent operations
set expandtab     " tab becomes spaces
set autoindent    " applies indent of current line to the next one
set smartindent   " reacts to syntax/style of code

set cursorline " highlight the current line

set clipboard=unnamedplus " use system clipboard

set laststatus=2          " make statusline appear even with single window
set statusline=%f         " filename
set statusline+=\ %r%m    " readonly, modified flags
set statusline+=%=        " right align the next part
set statusline+=%y        " filetype
set statusline+=\ (%l,%c) " line number, col number

set hlsearch  " highlight found words on search
set incsearch " jump to best fit
set showmatch " highlight matching parentheses

set showcmd " show commands as they are typed
let mapleader = "," " set leader key to comma

" Remove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

" Turn off search highlighting with <CR> (return).
nnoremap <CR> :nohlsearch<CR><CR>

lua << EOF
  -- Setup nvim-cmp
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
      end,
    },
    mapping = {
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    }
  })

  -- Setup lspconfig
  local lspconfig = require'lspconfig'

  lspconfig.pylsp.setup{
    capabilities = require'cmp_nvim_lsp'.update_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )
  }

  -- Setup treesitter
  require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained", -- one of "all", "maintained", or a list of languages
    -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
    higlight = {
      enable = false, -- false will disable the whole extension
      -- disable = { "c", "rust" }, -- List of languages that will be disabled
    },
    refactor = {
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = "grr",
        },
      },
    },
  }

  -- ccls for C/C++
  lspconfig.ccls.setup{}

  -- bashls for Bash scripts
  -- Requires install of bashls:
  --   (09-06-2021) sudo npm i -g bash-language-server
  lspconfig.bashls.setup{
    cmd_env = {
      GLOB_PATTERN = "**/*@(.sh|.inc|.bash|.command)"
    }
  }

  -- pylsp for Python
  lspconfig.pylsp.setup{}

  -- rust-analyzer for Rust
  lspconfig.rust_analyzer.setup{}

  -- vscode-html-language-server for HTML
  lspconfig.html.setup{}

  -- java-language-server for Java
  lspconfig.java_language_server.setup{}

  vim.o.completeopt = "menu,menuone,noselect"

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      return true
    else
      return false
    end
  end

  -- Use (s-)tab to:
  --   move to prev/next item in completion menuone
  --   jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif check_back_space() then
      return t "<Tab>"
    else
      return vim.fn['cmp#complete']()
    end
  end

  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-p>"
    else
      -- If <S-Tab> is not working in your terminal, change it to <C-h>
      return t "<S-Tab>"
    end
  end

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

  local nnn_actions = {};
  nnn_actions['<C-T>'] = 'tab drop';
  nnn_actions['<C-X>'] = 'split';
  nnn_actions['<C-V>'] = 'vsplit';
  require'nnn'.setup{
    action = nnn_actions,
    session = 'global',
    layout = { window = { width = 0.9, height = 0.6, highlight = 'Debug' } }
  }

  -- PyDocstring
  vim.g.pydocstring_formatter = "google"
  vim.g.pydocstring_templates_path = "~/.config/nvim/resources/pydoc"

  -- Instant Markdown
  -- Uncomment to override defaults:
  -- let g:instant_markdown_slow = 1
  -- let g:instant_markdown_autostart = 0
  -- let g:instant_markdown_open_to_the_world = 1
  -- let g:instant_markdown_allow_unsafe_content = 1
  -- let g:instant_markdown_allow_external_content = 0
  vim.g.instant_markdown_mathjax = 1
  -- let g:instant_markdown_mermaid = 1
  -- let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
  -- let g:instant_markdown_autoscroll = 0
  -- let g:instant_markdown_port = 8888
  -- let g:instant_markdown_python = 1
EOF

" HotKeys
"   Can see keybindings with `:Telescope keymaps`

" Run Telescope with ,,
nnoremap <Leader><Leader> :Telescope<CR>

" I prefer to use FZF for finding files. Can always access this through
" Telescope
" nnoremap <Leader>f :Telescope find_files<CR>
" Run FZF with ,f
nnoremap <Leader>f :FZF<CR>

" Run Telescope live grep with ,g
nnoremap <Leader>g :Telescope live_grep<CR>

" Run Telescope LSP definitions with ,d
nnoremap <Leader>d :Telescope lsp_definitions<CR>

" Run Telescope LSP references with ,r
nnoremap <Leader>r :Telescope lsp_references<CR>

" Run Telescope TreeSitter with ,s
nnoremap <Leader>s :Telescope treesitter<CR>

" Run NnnPicker with ,n
nnoremap <Leader>n :NnnPicker<CR>

" Toggle NerdTree with ,t
nnoremap <Leader>t :NERDTreeToggle<CR>

" Toggle Tagbar with ,b
nnoremap <Leader>b :TagbarToggle<CR>

" Set syntax highlighting for personal extensions
autocmd BufNewFile,BufRead *.howto set filetype=text

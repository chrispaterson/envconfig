syntax on
filetype plugin indent on

"""""""""""""""""""""""""""""""
" File Types
"""""""""""""""""""""""""""""""
au bufread,bufnewfile *.as set filetype=actionscript
au bufread,bufnewfile *.css set filetype=css
au bufread,bufnewfile *.html set filetype=html
au bufread,bufnewfile *.jade set filetype=jade
au bufread,bufnewfile *.java set filetype=java
au bufread,bufnewfile *.js,*.jsx set filetype=javascript
au bufread,bufnewfile *.json set filetype=json
au bufread,bufnewfile *.sass,*.scss set filetype=sass
au bufread,bufnewfile *.ts,*.tsx set filetype=typescript
au bufread,bufnewfile *.vue set filetype=vue

"""""""""""""""""""""""""""""""
" Set split locations
"""""""""""""""""""""""""""""""
set splitbelow
set splitright
set autoread

noremap <leader>i :NERDCommenterInsert<CR>

"""""""""""""""""""""""""""""""
" vim-plug
"""""""""""""""""""""""""""""""
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'https://tpope.io/vim/repeat.git'
Plug 'ervandew/supertab'
Plug 'leafgarland/typescript-vim'
Plug 'alvan/vim-closetag'
Plug 'chrispaterson/vim-colorschemes'
Plug 'chrispaterson/vim-colorschemes'
Plug 'pangloss/vim-javascript'
Plug 'heavenshell/vim-jsdoc'
Plug 'mxw/vim-jsx'
Plug 'peitalin/vim-jsx-typescript'
Plug 'tpope/vim-surround'
Plug 'posva/vim-vue'
Plug 'sekel/vim-vue-syntastic'
Plug 'styled-components/vim-styled-components'

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""
" JSDoc
"""""""""""""""""""""""""""""""
let g:jsdoc_enable_es6 = 1
let g:jsdoc_return = 1
let g:jsdoc_param_description_separator = '-'
noremap <leader>c :JsDoc<CR>


"""""""""""""""""""""""""""""""
" NERDTree
"""""""""""""""""""""""""""""""
" Move window focus to the right instead of on Nerdtree when openeing
autocmd VimEnter * wincmd p
" Toggle Nerd Tree on ctrl+n
map <C-n> :NERDTreeToggle<CR>
" show hidden files and folders in NerdTree
let NERDTreeShowHidden=1
" close VIM when only nertree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


"""""""""""""""""""""""""""""""
" Colors.  Themes at http://vimcolors.com/
"""""""""""""""""""""""""""""""
set background=dark
colorscheme Tomorrow-Night-Bright

"""""""""""""""""""""""""""""""
" Close Tag
"""""""""""""""""""""""""""""""
" filenames like *.xml, *.html, *.xhtml, ...
" Then after you press <kbd>&gt;</kbd> in these files, this plugin will try to close the current tag.
"
let g:closetag_filenames = '*.html,*.vue,*.jsx,*.tsx'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non closing tags self closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,vue,typescript.tsx,javascript.jsx,jsx,tsx,xhtml,phtml'

" integer value [0|1]
" This will make the list of non closing tags case sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'

""""
" NERDCommenter
""""
let s:NERDBlockCommentDelimiters = {
\   'left': '/** ','right': '*/'
\}
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = {
\   'javascript': s:NERDBlockCommentDelimiters,
\   'jsx': s:NERDBlockCommentDelimiters,
\   'typescript': s:NERDBlockCommentDelimiters,
\   'tsx': s:NERDBlockCommentDelimiters,
\   'vue': s:NERDBlockCommentDelimiters
\}
let g:NERDCommentEmptyLines = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1

""""
"general options
""""
set statusline=%l:%f
nnoremap <SPACE> <Nop>
let mapleader=" "

"indentation
set tabstop=4 softtabstop=0 expandtab shiftwidth=2 smarttab

"line number
set number
set ruler

"smarter search
set showmatch
set incsearch
set hlsearch

"other options
set showcmd
set noautochdir

"" Key Mappins"
map <C-S-H> <C-w>h
map <C-S-J> <C-w>j
map <C-S-K> <C-w>k
map <C-S-L> <C-w>l

nmap <silent> <leader>g <Plug>(diffget)

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)

tnoremap : <C-W><C-P>

" Use underline instead of reversing for errors and warnings
hi clear SpellBad
hi SpellBad cterm=bold,underline ctermfg=Red ctermbg=Black
hi clear SpellCap
hi SpellCap cterm=bold,underline ctermfg=Yellow ctermbg=Black
set signcolumn=yes

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL

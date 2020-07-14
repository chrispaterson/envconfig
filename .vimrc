syntax on
filetype plugin indent on

let g:jsx_ext_required = 0

" nerdtree stuff
" Move window focus to the right instead of on Nerdtree when openeing
autocmd VimEnter * wincmd p
" Toggle Nerd Tree on ctrl+n
map <C-n> :NERDTreeToggle<CR>
" show hidden files and folders in NerdTree
let NERDTreeShowHidden=1
" close VIM when only nertree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" FILETYPES
au bufread,bufnewfile *.jade set filetype=jade
au bufread,bufnewfile *.js set filetype=javascript
au bufread,bufnewfile *.ts set filetype=typescript
au bufread,bufnewfile *.vue set filetype=vue
au bufread,bufnewfile *.json set filetype=json
au bufread,bufnewfile *.as set filetype=actionscript
au bufread,bufnewfile *.java set filetype=java
au bufread,bufnewfile *.jsx set filetype=jsx
au bufread,bufnewfile *.css set filetype=css
au bufread,bufnewfile *.scss set filetype=sass
au bufread,bufnewfile *.sass set filetype=sass
au bufread,bufnewfile *.html set filetype=html

"""""""""""""""""""""""""""""""
" Syntax Checker with Syntastic
"""""""""""""""""""""""""""""""
set autoread

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_jump = 3

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_json_checkers = ['eslint']
let g:syntastic_typescript_checkers = ['eslint']
let g:syntastic_vue_checkers = ['eslint']

"""""""""""""""""""""""""""""""
" Ale (auto fixer)
"""""""""""""""""""""""""""""""
let g:ale_completion_tsserver_autoimport = 1
let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'typescript': ['tsserver','eslint'],
\   'javascript': ['eslint'],
\   'vue': ['tsserver', 'eslint'],
\   'json': ['eslint']
\}
let g:ale_linters_explicit = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'typescript': ['eslint'],
\   'javascript': ['eslint'],
\   'vue': ['eslint'],
\   'json': ['eslint'],
\   'html': ['prettier']
\}

"""""""""""""""""""""""""""""""
" JsDoc
"""""""""""""""""""""""""""""""
let g:jsdoc_enable_es6 = 1
let g:jsdoc_return = 1
let g:jsdoc_param_description_separator = '-'

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
let g:closetag_filenames = '*.html,*.jsx,*.vue'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non closing tags self closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,vue,jsx,tsx,xhtml,phtml'

" integer value [0|1]
" This will make the list of non closing tags case sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '<C->>'


""""
" NERDCommenter
""""
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = {
\   'javascript': { 'left': '/** ','right': '*/' },
\   'typescript': { 'left': '/** ','right': '*/' },
\   'vue': { 'left': '/** ','right': '*/' }
\}
let g:NERDCommentEmptyLines = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1

""""
"general options
""""
set statusline=%l:%f
let mapleader=","

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

autocmd FileType javascript noremap <leader>d :JsDoc<CR>
autocmd FileType typescript noremap <leader>d :JsDoc<CR>
autocmd FileType javascript noremap <leader>ci :NERDCommenterInsert<CR>
autocmd FileType typescript noremap <leader>ci :NERDCommenterInsert<CR>

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
noremap <F8> :lprevious<CR>
noremap <F9> :lnext<CR>
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

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

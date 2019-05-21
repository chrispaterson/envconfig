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
au bufread,bufnewfile *.json set filetype=json
au bufread,bufnewfile *.as set filetype=actionscript
au bufread,bufnewfile *.java set filetype=java
au bufread,bufnewfile *.jsx set filetype=jsx
au bufread,bufnewfile *.css set filetype=css
au bufread,bufnewfile *.html set filetype=html


"""""""""""""""""""""""""""""""
" Syntax Checker with Syntastic
"""""""""""""""""""""""""""""""
set autoread

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_json_checkers = ['eslint']
#let g:syntastic_typescript_checkers = ['eslint', 'tsc']
let g:syntastic_typescript_checkers = ['tsuquyomi']
"let g:syntastic_html_checkers = ['/usr/local/Cellar/tidy-html5/5.4.0/bin/tidy']
"
" use the local version of eslint via the project
 let g:syntastic_javascript_eslint_exec = './node_modules/.bin/eslint'
 let g:syntastic_json_eslint_exec = './node_modules/.bin/eslint'
 #let g:syntastic_typescript_eslint_exec = './node_modules/.bin/eslint'


"""""""""""""""""""""""""""""""
" Ale (auto fixer)
"""""""""""""""""""""""""""""""
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'json': ['eslint'],
\}
let g:ale_fix_on_save = 1

"""""""""""""""""""""""""""""""
" JsDoc
"""""""""""""""""""""""""""""""
let g:jsdoc_enable_es6 = 1
let g:jsdoc_return = 1
let g:jsdoc_param_description_separator = ' - '

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
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non closing tags self closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" integer value [0|1]
" This will make the list of non closing tags case sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'

""""
" NERDCommenter
""""
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'javascript': { 'left': '/** ','right': '*/' } }

""""
"general options
""""

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
noremap <F4> :lnext<CR>
noremap <F3> :lnext<CR>
noremap <F5> :JsDoc<CR>
set laststatus=2
set statusline=%f "tail of the filename

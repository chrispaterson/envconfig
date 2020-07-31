let b:ale_linter_aliases =  ['vue', 'typescript', 'scss']
let b:ale_linters = ['vls', 'eslint', 'stylelint']
let b:ale_fixers = ['eslint', 'stylelint']
let b:ale_set_balloons = 1

"" Key Mappins"
noremap <leader>d :JsDoc<CR>
noremap <leader>ci :NERDCommenterInsert<CR>

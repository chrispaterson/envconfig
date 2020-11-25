let b:ale_linters = ['tsserver', 'eslint']
let b:ale_fixers = ['eslint']

map <leader>d :ALEGoToDefinitionInVSplit<enter>
map <leader>t :ALEGoToTypeDefinition<enter>
map <leader>o :ALEOrganizeImports<enter>
map <leader>r :ALERename<enter>
map <leader>i :ALEHover<enter>

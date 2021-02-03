let b:ale_linters = ['tsserver', 'eslint']
let b:ale_fixers = ['eslint']

map <leader>d :ALEGoToDefinitionInVSplit<enter>
map <leader>t :ALEGoToTypeDefinition<enter>
map <leader>o :ALEOrganizeImports<enter>
map <leader>r :ALERename<enter>
map <leader>i :ALEHover<enter>

if filereadable(expand('%'))
  " BufRead
else
  " BufNewFile
  call append(line('$'), "import React, { ReactElement } from 'react';")
  call append(line('$'), "")
  call append(line('$'), "export default function " . expand('%:t:r') . "(): ReactElement {")
  call append(line('$'), "")
  call append(line('$'), "}")
endif

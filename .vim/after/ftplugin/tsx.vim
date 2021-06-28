let b:ale_linters = ['tsserver', 'eslint']
let b:ale_fixers = ['eslint']

"""""""""""""""""""""""""""""""
" JsDoc
"""""""""""""""""""""""""""""""
let b:jsdoc_formatter = 'tsdoc'

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

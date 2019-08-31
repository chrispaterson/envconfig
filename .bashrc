#!/bin/bash

[[ $- == *i* ]] || return 0

ENV_FILE=~/.env
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

# Command Prompt things with git
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

#Aliases for shortcut things
alias sp="source ~/.profile"
alias ep="vi ~/.profile"
alias ..="cd ../"

#Aliased commands so I don't have to remember the details
alias makeMDTOC="npx markdown-toc --no-firsth1"

# only on linux -- OSX will throw an error if I pass the --color=auto
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias ls='ls --color=auto'
fi
alias ll='ls -GlA'
alias l='ls -Gl'

#Add bin to path
export PATH="$PATH:~/bin"

export DPE_QA="dtsjc00gdp01q.dc.dotomi.net"

source ~/.nvmstuff

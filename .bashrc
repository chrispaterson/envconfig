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

alias ll='ls -GlA'
alias l='ls -Gl'

source ~/.nvmstuff

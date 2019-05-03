#!/bin/bash

[[ $- == *i* ]] || return 0

if ! [ $ENV_SOURCED ]; then
  source ~/.env
fi

# Command Prompt things with git
. ~/.bash/git-aware-prompt/main.sh
PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

#Aliases for shortcut things
alias sp="source ~/.profile"
alias ep="vi ~/.profile"
alias ..="cd ../"
alias ls='ls -G'
alias ll='ls -hla'
alias l='ls -l'

source ~/.nvmstuff

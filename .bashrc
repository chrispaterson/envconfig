#!/bin/bash

[[ $- == *i* ]] || return 0

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

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

if [[ $machine != Mac ]]; then

  # This happens automatically on a Mac
  alias ls='ls -G --color=auto'
fi

alias ll='ls -la'
alias l='ls -l'

source ~/.nvmstuff

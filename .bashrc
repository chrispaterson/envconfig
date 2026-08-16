#!/bin/bash

[[ $- == *i* ]] || return 0

source "$HOME/.shrc"

# Command Prompt things with git
export GITAWAREPROMPT=$HOME/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
#PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"


if [[ "$OSTYPE" == "linux-gnu" ]]; then

  # Linux

  # only on linux -- OSX will throw an error if I pass the --color=auto
  alias ls='ls --color=auto'

fi

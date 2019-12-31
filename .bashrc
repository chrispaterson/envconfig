#!/bin/bash

[[ $- == *i* ]] || return 0

source $HOME/.shrc

# Command Prompt things with git
export GITAWAREPROMPT=$HOME/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

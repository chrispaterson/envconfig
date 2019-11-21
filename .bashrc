#!/bin/bash

[[ $- == *i* ]] || return 0

ENV_FILE=$HOME/.env
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

# Command Prompt things with git
export GITAWAREPROMPT=$HOME/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

#Aliases for shortcut things
alias ..="cd ../"
# only on linux -- OSX will throw an error if I pass the --color=auto
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias ls='ls --color=auto'
fi
alias ll='ls -GlA'
alias l='ls -Gl'

# Always open files in vertical split mode
alias vi='vim -O'

npm() {
  if [[ $1 == "install" ]]; then
    if [[ -z $2 ]]; then
      command yarn install
    else
      command yarn add $2
    fi
  else
    command npm "$@"
  fi
}

#Add bin to path
export PATH="$HOME/bin:$PATH"

source $HOME/.nvmstuff
source $HOME/.ruststuff

# Ruby stuff
export PATH="/usr/local/opt/ruby/bin:$HOME/.gem/ruby/2.6.0/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
eval "$(rbenv init -)"

source /usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme

ENV_FILE=$HOME/.env
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

#Aliases for shortcut things
alias ..="cd ../"

alias ll='ls -GlA'
alias l='ls -Gl'

# Always open files in vertical split mode
alias vi='vim -O'

#Add bin to path
export PATH="$HOME/bin:$HOME/node_bin/node_modules/.bin:$PATH"

source $HOME/.nvmstuff

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='006'
POWERLEVEL9K_DIR_HOME_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_FOREGROUND='magenta'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='magenta'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='white'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='red'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs)

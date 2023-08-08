#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/.shrc

source "$HOMEBREW_PREFIX/opt/powerlevel10k/powerlevel10k.zsh-theme"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='006'
POWERLEVEL9K_DIR_HOME_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_FOREGROUND='magenta'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='magenta'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='081'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='202'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# turn on tab auto complete
autoload -Uz compinit && compinit -u

# Automatically use nvm if an nvmrc is detected
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
      $HOME/bin/yarn-global
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
      $HOME/bin/yarn-global
    fi
  fi
}

bindkey -v

add-zsh-hook chpwd load-nvmrc


# See if this rc is being sourced in a git repo
git rev-parse --is-inside-git-dir > /dev/null 2>&1

# if the last command succeeded then nvm is a thing
if [[ $? == 0 ]]; then 
  load-nvmrc
fi

_pkg() {
  compadd $(rush_project_names)
}

compdef _pkg pkg

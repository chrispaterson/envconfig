#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/.shrc

source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

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



GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
export GIT_ROOT

#autoload -U add-zsh-hook
#add-zsh-hook chpwd

# turn on tab auto complete
autoload -Uz compinit && compinit -u

# Automatically use nvm if an nvmrc is detected
autoload -U add-zsh-hook
load-nvmrc() {
  [[ -z "$GIT_ROOT" ]] && return

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

autoload -U add-zsh-hook
bindkey -v
load-nvmrc

# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

# ensure no alias interferes with function definition
unalias vi 2>/dev/null
vi() {
  if [ -n "$CURSOR_TRACE_ID" ]; then
    command cursor "$@"
  else
    command vim -O "$@"
  fi
}

# pnpm
export PNPM_HOME="/Users/paterson/Library/pnpm/global/5"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

path_for_pkg_name() {
  rush list --json | jq -r --arg name "$1" '.projects[] | select(.name | endswith("/" + $name)) | .path'
}

pkg() {
	if [ $# -eq 0 ]; then
    rush list
		return 0
	fi
	if ! rush list >/dev/null 2>&1; then
		return 1
	fi
  
  target_dir="$(git rev-parse --show-toplevel 2>/dev/null)/$(path_for_pkg_name $1)"
	if [ ! -d "$target_dir" ]; then
		echo "Package $1 does not exist."
		return 1
	fi
	cd "$target_dir"
}

# zsh autocomplete for `pkg`
_pkg_zsh_autocomplete() {
  # bail if rush isn’t available or not in a repo
  local json
  json="$(rush list --json 2>/dev/null)" || return

  local -a packages
  packages=(${(f)"$(
    jq -r '
      .projects[]
      | .name
      | split("/")[-1]
    ' <<< "$json"
  )"})

  _describe 'package' packages
}

# register completion
compdef _pkg_zsh_autocomplete pkg

# Update package autocomplete on branch switch in git
autoload -Uz add-zsh-hook

_refresh_pkg_autocomplete_cache() {
  # This will re-register the compdef for 'pkg'
  if type compdef >/dev/null 2>&1; then
    compdef _pkg_zsh_autocomplete pkg
  fi
}

# Add a Zsh hook for every time before a command is run
_git_branch_switch_hook() {
  local last_cmd="${1:-}"
  # Look for 'git checkout', 'git switch', 'git worktree', or 'gco' aliases that may change branches
  if [[ "$last_cmd" =~ ^git\ (checkout|switch|worktree\ switch|worktree\ add|checkout\ -b) ]]; then
    _refresh_pkg_autocomplete_cache
  fi
}

add-zsh-hook precmd _refresh_pkg_autocomplete_cache
add-zsh-hook preexec _git_branch_switch_hook

_WT_PREV_DIR=""

unalias wt 2>/dev/null
wt() {
  if [[ "$1" == "-" ]]; then
    if [[ -z "$_WT_PREV_DIR" ]]; then
      echo "wt: no previous worktree" >&2
      return 1
    fi
    local dest="$_WT_PREV_DIR"
    _WT_PREV_DIR="$PWD"
    cd "$dest"
    return
  fi

  if [[ -z "$1" ]]; then
    echo "Usage: wt <worktree-name> | wt -" >&2
    return 1
  fi

  local current_root
  current_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$current_root" ]]; then
    echo "wt: not in a git repository" >&2
    return 1
  fi

  local rel_path="${PWD#$current_root}"

  local -a worktrees
  worktrees=("${(@f)$(git worktree list --porcelain | awk '$1 == "worktree" { print $2 }')}")

  local main_root="${worktrees[1]}"
  local parent_dir="${main_root:h}"

  local target_root=""
  if [[ "$1" == "root" ]]; then
    target_root="$main_root"
  else
    local wt_path
    for wt_path in "${worktrees[@]}"; do
      if [[ "${wt_path#$parent_dir/}" == "$1" ]]; then
        target_root="$wt_path"
        break
      fi
    done
  fi

  if [[ -z "$target_root" ]]; then
    echo "wt: worktree '$1' not found" >&2
    return 1
  fi

  local dest="${target_root}${rel_path}"
  [[ -d "$dest" ]] || dest="$target_root"

  _WT_PREV_DIR="$PWD"
  cd "$dest"
}

_wt_zsh_autocomplete() {
  local current_root
  current_root=$(git rev-parse --show-toplevel 2>/dev/null) || return

  local -a worktrees
  worktrees=("${(@f)$(git worktree list --porcelain | awk '$1 == "worktree" { print $2 }')}")

  local main_root="${worktrees[1]}"
  local parent_dir="${main_root:h}"

  local -a names
  names+=("root")
  local wt_path
  for wt_path in "${worktrees[@]}"; do
    [[ "$wt_path" == "$current_root" ]] && continue
    names+=("${wt_path#$parent_dir/}")
  done

  _describe 'worktree' names
}

compdef _wt_zsh_autocomplete wt

_git-b() {
  local curcontext="$curcontext" state

  _arguments \
    '(-d --delete)'{-d,--delete}'[Delete local and remote branch]: :->branch' \
    '(-h --help)'{-h,--help}'[Show help]'

  case $state in
    branch)
      local -a branches
      branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})
      _describe 'branch' branches
      ;;
  esac
}

# bun completions
[ -s "/Users/paterson/.bun/_bun" ] && source "/Users/paterson/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# >>> scout completion >>>
command -v scout >/dev/null 2>&1 && eval "$(scout generate-shell-completion zsh)"
# <<< scout completion <<<

<<<<<<< Updated upstream
# ---------------------------------------------------------------------------
# Terminal tab titles
#
# Terminal.app takes its tab title from the OSC 1 escape sequence. Emitting an
# empty title hands naming back to Terminal's own default (working directory /
# active process), so that doubles as the "reset" value. _TERM_TAB_TITLE
# remembers a manually set title so the ssh wrapper can restore it on exit.
# ---------------------------------------------------------------------------
_TERM_TAB_TITLE=""

_term_set_tab_title() {
  [[ -t 1 ]] || return
  printf '\e]1;%s\a' "$1"
}

# title "some name"  -> rename the tab; bare `title` clears it back to default.
title() {
  _TERM_TAB_TITLE="$*"
  _term_set_tab_title "$_TERM_TAB_TITLE"
}

# Name the tab after the remote host for the duration of an ssh session.
ssh() {
  local dest="" host="" arg
  local -i skip=0 ret=0

  for arg in "$@"; do
    if (( skip )); then
      skip=0
      continue
    fi
    case "$arg" in
      # Options whose value is the following argument; skip that argument so a
      # value like a port or config file is never mistaken for the destination.
      -*[bBcDEeFIiJLlmOoPpQRSWw]) skip=1 ;;
      -*) ;;
      *) dest="$arg"; break ;;
    esac
  done

  # Destinations may arrive as host, user@host, or ssh://user@host:port/path.
  host="${dest#ssh://}"
  host="${host%%/*}"
  host="${host##*@}"
  host="${host%%:*}"

  if [[ -n "$host" ]]; then
    _term_set_tab_title "$host"
  fi

  command ssh "$@"
  ret=$?

  if [[ -n "$host" ]]; then
    _term_set_tab_title "$_TERM_TAB_TITLE"
  fi

  return $ret
}

# Added by cua-driver-rs installer — see https://github.com/trycua/cua
export PATH="/Users/chrispaterson/.local/bin:$PATH"

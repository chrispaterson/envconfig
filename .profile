#paths
export EDITOR=vi
export MANPATH=/opt/local/share/man:$MANPATH
export CLICOLOR=1
export TERM=xterm-color
export LSCOLORS=DxGxcxdxCxegedabagacad

# Command Prompt things with git
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
PS1="\n\[\$bldwht\]\w \[$txtrst\]\$git_branch \$git_dirty \$git_ahead_behind\n\[$txtpur\]↳ \[$txtrst\]"

#Aliases for shortcut things
alias sp="source ~/.profile"
alias ep="vi ~/.profile"
alias ..="cd ../"
alias ls='ls -G'
alias ll='ls -hla'
alias l='ls -l'
alias gitlog='git log --graph --decorate --pretty=oneline --abbrev-commit'
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"
alias showhidden="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"

if [[ ! -z "$(command -v nvm)" ]]; then

  nvm use 10.12.0
fi


#!/bin/sh

export EDITOR="vim"
export PATH="$PATH:/opt/homebrew/bin"

if [ $SHELL = "/bin/bash" ]; then

  source $HOME/.bashrc

elif [ $SHELL = "/bin/zsh" ]; then

  source $HOME/.zshrc

fi

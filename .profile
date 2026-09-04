#!/bin/sh

export EDITOR="vim"

if [ $SHELL = "/bin/bash" ]; then

  source $HOME/.bashrc

elif [ $SHELL = "/bin/zsh" ]; then

  source $HOME/.zshrc

fi

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

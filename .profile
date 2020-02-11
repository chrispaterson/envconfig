#!/bin/sh

export EDITOR="vim"

if [ $SHELL = "/bin/bash" ]; then

  source $HOME/.bashrc

elif [ $SHELL = "/bin/zsh" ]; then

  source $HOME/.zshrc

fi

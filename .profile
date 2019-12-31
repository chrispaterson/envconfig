#!/bin/sh

export EDITOR="vim"

if [ $SHELL = "/bin/bash" ]; then

  echo "Shell is bash"
  source $HOME/.bashrc

elif [ $SHELL = "/bin/zsh" ]; then

  echo "Shell is zsh"
  source $HOME/.zshrc

fi

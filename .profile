#!/bin/bash

export EDITOR="vim"

if [ "$BASH" ]; then
 source ~/.bashrc
fi

if ! [ $ENV_SOURCED ]; then
  source ~/.env
fi

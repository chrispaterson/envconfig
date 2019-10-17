#!/bin/bash

export EDITOR="vim"

if [ "$BASH" ]; then
 source ~/.bashrc
fi

export PATH="$HOME/.cargo/bin:$PATH"

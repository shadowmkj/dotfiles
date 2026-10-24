#!/usr/bin/env bash

cd ~/thirdparty

git clone --depth=1 -b 3.8 https://github.com/tmux/tmux

cd tmux
sh autogen.sh
./configure && make -j$(nproc)


#!/usr/bin/env bash

cd ~/thirdparty

git clone --depth=1 -b nightly https://github.com/neovim/neovim

cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install -j$(nproc)


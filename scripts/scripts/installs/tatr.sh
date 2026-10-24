#!/usr/bin/env bash

cd ~/thirdparty

git clone --depth=1 https://github.com/tsoding/tatr
cd tatr

cc -o nob nob.c
./nob
sudo cp ./build/tatr /usr/local/bin/

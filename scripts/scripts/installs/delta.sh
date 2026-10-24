#!/usr/bin/env bash

cd ~/thirdparty

git clone --depth=1 https://github.com/dandavison/delta
cd delta

cargo build --release

mv ./target/release/delta /usr/local/bin/

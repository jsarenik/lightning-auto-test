#!/bin/sh -e

cd ~/src/lightning
git submodule deinit --all --force
git clean -xffd
git tag -l | xargs git tag -d && git fetch -t
git fetch origin
git rebase origin/master
git submodule update --init --recursive
./configure --enable-developer --enable-valgrind
make -j4
make PREFIX=$HOME/lightning-my install

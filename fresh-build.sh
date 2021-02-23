#!/bin/sh -e

cd ~/src/lightning
git checkout master
git submodule deinit --all --force
git clean -xffd
git tag -l | xargs git tag -d && git fetch -t
git pull
./configure
make -j4
make PREFIX=$HOME/lightning-my install

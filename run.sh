#!/bin/sh

set -xe
export TZ=UTC
export LC_ALL=C
export LANG=C
URL=https://github.com/ElementsProject/lightning.git
#"https://github.com/jsarenik/lightning -b jasan/libwally_update_2"

{

date
rm -rf lightning
git clone $URL
cd lightning
./configure --disable-developer --disable-valgrind
make -j4
make check
make check-source

} 2>&1 | tee log

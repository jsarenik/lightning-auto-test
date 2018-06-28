#!/bin/sh

set -xe
export TZ=UTC
export LC_ALL=C
export LANG=C
URL=https://github.com/ElementsProject/lightning.git
#"https://github.com/jsarenik/lightning -b jasan/libwally_update_2"

myclone() {
	dir=${1##*/}
	dir=${dir%%.git}
	rm -rf $dir
	git clone $1
}

{

date
uname -r
uname -v
cat /etc/os-release
bitcoind --version
pip3 freeze --local
myclone $URL
rm -rf lightning-rfc
#myclone https://github.com/lightningnetwork/lightning-rfc
cd lightning
git rev-parse HEAD
./configure --disable-developer --disable-valgrind
make -j4
make TIMEOUT=120 check
make check-source

} 2>&1 | tee log

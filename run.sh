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

armrandom() {
	myarch=$(uname -m)
	test "$myarch" = "armv7l" && {
		mv /dev/random /dev/random-old
		ln -s urandom /dev/random
		echo 1
	}
	return 0
}

{

unset ARMRANDOM
ARMRANDOM=$(armrandom) || true

date
uname -r
uname -v
cat /etc/os-release
myclone $URL
rm -rf lightning-rfc
#myclone https://github.com/lightningnetwork/lightning-rfc
cd lightning
git rev-parse HEAD
./configure --disable-developer --disable-valgrind
time -p make -j4
bitcoind --version
pip3 install -r tests/requirements.txt
pip3 freeze --local
time -p make TIMEOUT=120 check
cppcheck --version
shellcheck --version
make check-source

test -n "$ARMRANDOM" && {
	rm /dev/random
	mv /dev/random-old /dev/random
}

} 2>&1 | tee log

#!/bin/sh

set -xe
export TZ=UTC
URL=https://github.com/ElementsProject/lightning.git
#"https://github.com/jsarenik/lightning -b jasan/libwally_update_2"

myclone() {
	dir=${1##*/}
	dir=${dir%%.git}
	if
		test -d $dir
	then
		cd $dir
		git add -A
		git stash
		git fetch --all --prune
		git checkout master
		git clean -xfd
		git submodule deinit --all --force
		git pull
		cd -
	else
		git clone $1
	fi
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

PYTHON3=$(which python3)
type time pip3 bitcoind
date
git rev-parse HEAD
uname -srm
uname -v
cat /etc/os-release
myclone $URL
rm -rf lightning-rfc
#myclone https://github.com/lightningnetwork/lightning-rfc
cd lightning
git rev-parse HEAD

pip3 install --user virtualenv
export PATH=$HOME/.local/bin:$PATH
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
virtualenv -p $PYTHON3 ../virtualenv
. ../virtualenv/bin/activate
pip install --upgrade pip
pip install -r tests/requirements.txt

./configure --enable-developer --disable-valgrind
time -p make -j4
bitcoind --version
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

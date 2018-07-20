#!/bin/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; BINDIR=$(cd $a; pwd)

set -xe
export TZ=UTC
URL=${1:-"https://github.com/ElementsProject/lightning.git"}
BRANCH=${2:-"master"}

renamelog() {
	set +e
	REV=$(grep LIGHTNING_REV $BINDIR/log | cut -d= -f2)
	REV=${REV:-"early_log"}
	ADD=0
	cd $BINDIR
	while test -r ${REV}-${ADD}.log
	do ADD=$((ADD+1)); done
	mv log ${REV}-${ADD}.log
	exit 0
}
trap "renamelog" INT QUIT

myclone() {
	myurl=${1}
	test -n "$myurl"
	mybranch=${2:-"master"}
	dir=${1##*/}
	dir=${dir%%.git}
	if
		test -d $dir
	then
		cd $dir
		git add -A
		git stash
		git remote -v show | grep origin | grep -q $URL || {
			git remote rm origin
			git remote add origin $URL
		}
		git fetch --all --prune
		git checkout $mybranch
		git clean -xfd
		git submodule deinit --all --force
		git branch --set-upstream-to=origin/$mybranch
		git pull
		cd -
	else
		git clone $myurl -b $mybranch
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

date

: This is https://github.com/jsarenik/lightning-auto-test
pwd
git rev-parse --short HEAD

unset ARMRANDOM
ARMRANDOM=$(armrandom) || true

PYTHON3=$(which python3)
type time pip3 bitcoind bitcoin-cli cppcheck shellcheck
uname -srm
uname -v
cat /etc/os-release
myclone $URL $BRANCH

# Make sure to remove lightning-rfc for now
	rm -rf lightning-rfc
	#myclone https://github.com/lightningnetwork/lightning-rfc

cd lightning
pwd
LIGHTNING_REV=$(git rev-parse --short HEAD)

pip3 install --user virtualenv
export PATH=$HOME/.local/bin:$PATH
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
virtualenv -p $PYTHON3 ../virtualenv
set +x
. ../virtualenv/bin/activate
set -x
pip install --upgrade pip
pip install -r tests/requirements.txt

export DEVELOPER=${DEVELOPER:-1}
export VALGRIND=${VALGRIND:-0}
./configure
NUMCORES=$(grep -c ^processor /proc/cpuinfo)
time -p make -j$NUMCORES
bitcoind --version
pip3 freeze --local
time -p make TIMEOUT=120 check
cppcheck --version
shellcheck --version
pip3 install flake8
make check-source

test -n "$ARMRANDOM" && {
	rm /dev/random
	mv /dev/random-old /dev/random
}

} 2>&1 | tee $BINDIR/log

#!/bin/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; BINDIR=$(cd $a; pwd)

set -xe
export TZ=UTC
URL=${1:-"https://github.com/ElementsProject/lightning.git"}
BRANCH=${2:-"master"}
RET=1

renamelog() {
	set +e
	REV=$(grep LIGHTNING_REV $BINDIR/log | cut -d= -f2)
	REV=${REV:-"early_log"}
	ADD=0
	cd $BINDIR
	while test -r ${REV}-${ADD}.log
	do ADD=$((ADD+1)); done
	mv log ${REV}-${ADD}.log
	exit $RET
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
		git status -s | grep . && {
			git add -A
			git stash
		}
		git remote -v show | grep origin | grep -q $myurl || {
			git remote rm origin
			git remote add origin $myurl
		}
		git fetch --all --prune
		git checkout $mybranch
		git branch --set-upstream-to=origin/$mybranch
		git reset --hard origin/$mybranch
		git clean -xffd
		git submodule deinit --all --force
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
myclone https://github.com/lightningnetwork/lightning-rfc

cd lightning
pwd
LIGHTNING_REV=$(git rev-parse --short HEAD)

VENV=../virtualenv
export PATH=$HOME/.local/bin:$PATH
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
test -r $VENV/venv-installation-part1 || {
	pip3 install --user virtualenv
	virtualenv -p $PYTHON3 $VENV
	touch $VENV/venv-installation-part1
}
set +x
. $VENV/bin/activate
set -x
test -r $VENV/venv-installation-part2 || {
	pip install --upgrade pip
	pip install -r tests/requirements.txt
	touch $VENV/venv-installation-part2
}

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
RET=$?
: Exited with $RET

test -n "$ARMRANDOM" && {
	rm /dev/random
	mv /dev/random-old /dev/random
}

} 2>&1 | tee $BINDIR/log
renamelog

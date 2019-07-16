#!/bin/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; BINDIR=$(cd $a; pwd)

# You are already in lightning directory, checked-out
set -xe
export TZ=UTC
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

mybranch=${1:-"master"}
rm -rf .tmp.lightningrfc
git status -s | grep . && {
	git add -A
	git stash
}
git clean -xffd
git submodule deinit --all --force

{

date

: This is https://github.com/jsarenik/lightning-auto-test run-manual.sh
pwd
git rev-parse --short HEAD

PYTHON3=$(which python3)
type time pip3 bitcoind bitcoin-cli cppcheck shellcheck
uname -srm
uname -v
#cat /etc/os-release

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

} 2>&1 | tee $BINDIR/log
renamelog

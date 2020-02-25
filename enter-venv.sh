#!/bin/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; BINDIR=$(cd $a; pwd)

# You are already in lightning directory, checked-out
set -xe
export TZ=UTC
RET=1


PYTHON3=$(which python3)
type time pip3 bitcoind bitcoin-cli cppcheck shellcheck
uname -srm
uname -v
#cat /etc/os-release

pwd
LIGHTNING_REV=$(git rev-parse --short HEAD)

VENV=../virtualenv
export PATH=$HOME/.local/bin:$PATH
unset LC_ALL
unset LANG
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
	test -r tests/requirements.txt \
	  && pip install -r tests/requirements.txt \
	  || pip install -r requirements.txt
	touch $VENV/venv-installation-part2
}

export DEVELOPER=${DEVELOPER:-1}
export VALGRIND=${VALGRIND:-0}
test -r config.vars || {
echo File config.vars not found
echo "Really you want to configure? [N/y]:"
read really
test "$really" = "y" -o "$really" = "Y" && {
rm -rf .tmp.lightningrfc
git clean -xffd
git submodule deinit --all --force
./configure
NUMCORES=$(grep -c ^processor /proc/cpuinfo)
time -p make -j$NUMCORES
} || true
}
$SHELL
exit

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

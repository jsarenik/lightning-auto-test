#!/bin/sh

set -xe
export TZ=UTC
URL=${1:-"https://github.com/ElementsProject/lightning.git"}
BRANCH=${2:-"master"}

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
type time pip3 bitcoind cppcheck shellcheck
uname -srm
uname -v
cat /etc/os-release
myclone $URL $BRANCH

# Make sure to remove lightning-rfc for now
	rm -rf lightning-rfc
	#myclone https://github.com/lightningnetwork/lightning-rfc

cd lightning
pwd
LIGHTNING_REV=$(git rev-parse HEAD)

pip3 install --user virtualenv
export PATH=$HOME/.local/bin:$PATH
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
virtualenv -p $PYTHON3 ../virtualenv
. ../virtualenv/bin/activate
pip install --upgrade pip
pip install -r tests/requirements.txt

./configure --enable-developer --disable-valgrind
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

} 2>&1 | tee log

unset ADD=0
while test -r ${LIGHTNING_REV}-${ADD}.log
do ADD=$((ADD+1)); done
echo Moving log to ${LIGHTNING_REV}-${ADD}.log
mv log ${LIGHTNING_REV}-${ADD}.log

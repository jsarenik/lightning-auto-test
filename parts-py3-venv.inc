# included from run*.sh

PYTHON3=$(which python3)
test -r /usr/local/include/secp256k1.h || test -r /usr/include/secp256k1.h \
  || { echo "Secp256k1 not found!"; exit 1; }

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
NOWDIR=$PWD
installpip() {
	cd contrib/$1
	test -f requirements.txt && pip install -r requirements.txt
	pip install .
	cd $NOWDIR
}
test -r $VENV/venv-installation-part2 || {
	pip install --upgrade pip
	pip install -r requirements.lock
#	pip install --use-feature=in-tree-build \
#		./contrib/pyln-client \
#		./contrib/pyln-proto \
#		./contrib/pyln-testing
	installpip pyln-client
	installpip pyln-proto
	installpip pyln-testing
	#installpip pyln-spec/bolt1
	#installpip pyln-spec/bolt2
	#installpip pyln-spec/bolt4
	#installpip pyln-spec/bolt7
	pip3 install \
		blinker \
		flake8 \
		flaky \
		mako \
		pytest-sentry \
		pytest-test-groups==1.0.3 \
		pytest-custom-exit-code==0.3.0 \
		pytest-timeout \
		pytest-json-report

#	test -r tests/requirements.txt \
#	  && pip install -r tests/requirements.txt \
#	  || pip install -r requirements.txt

	touch $VENV/venv-installation-part2
}

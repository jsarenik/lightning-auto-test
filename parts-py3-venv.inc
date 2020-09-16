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
test -r $VENV/venv-installation-part2 || {
	pip install --upgrade pip
	test -r tests/requirements.txt \
	  && pip install -r tests/requirements.txt \
	  || pip install -r requirements.txt
	pip install --upgrade pip

	pip install base58 mrkd bitstring secp256k1 cryptography coincurve
	pip install mako
	touch $VENV/venv-installation-part2
}

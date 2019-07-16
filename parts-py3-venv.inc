# included from run*.sh

PYTHON3=$(which python3)

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
	pip install mako
	touch $VENV/venv-installation-part2
}

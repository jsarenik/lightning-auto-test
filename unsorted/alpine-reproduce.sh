#!/bin/sh

# requirements
type sudo tar wget

# see https://alpinelinux.org/downloads/ for more architectures,
# the rest are scripts and should work on all architectures
AMAC=x86_64
AVER=3.15.0
AURL="http://dl-cdn.alpinelinux.org/alpine/v${AVER%.*}/releases"
CHSYS="https://raw.githubusercontent.com/jsarenik/dotfiles/master/bin/chsys"
ALPINE="$AURL/$AMAC/alpine-minirootfs-$AVER-$AMAC.tar.gz"

MYCH=/workspace/chsys
cd $MYCH || {
	mkdir -p $MYCH/var/tmp/
	cd $MYCH
	wget $ALPINE
	wget $CHSYS
	chmod a+x chsys

	# Extract Alpine root
	mkdir alpine
	sudo tar -xf ${ALPINE##*/} -C alpine
	sudo chmod a+rx alpine
}

# Script that is run inside chroot
cat >$MYCH/alpine/var/tmp/script <<EOF
apk update
apk upgrade
apk add git libtool autoconf automake \
  file g++ make libc-dev patch \
  python3-dev gmp-dev sqlite-dev zlib-dev cppcheck \
  py3-pip gettext libpq-dev libsecp256k1-dev libffi-dev jq
pip install mako mrkd mistune==0.8.4 coincurve
apk add db-c++ db boost db-dev boost-dev libressl-dev libevent-dev
apk add py3-pyrsistent
cat > /usr/local/bin/shellcheck <<-EOOOF
	#!/bin/sh
	true
	EOOOF
chmod a+x /usr/local/bin/shellcheck
export CFLAGS="-pipe -s -march=native -mtune=native -O3"
export LDFLAGS="-s -no-pie"
git clone -b 22.x https://github.com/bitcoin/bitcoin
cd bitcoin
./autogen.sh
./configure \
  --with-incompatible-bdb \
  --without-gui \
  --disable-zmq
make -j2 install
cd ..
git clone https://github.com/jsarenik/lightning-auto-test
cd lightning-auto-test
export DEVELOPER=1
./run.sh
EOF

sudo ./chsys alpine sh /var/tmp/script

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

MYCH=$HOME/chsys
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
apk add git bitcoin bitcoin-cli libtool autoconf automake build-base python3-dev gmp-dev sqlite-dev zlib-dev cppcheck
#apk add db-c++ db boost db-dev boost-dev libressl-dev libevent-dev
cat > /usr/local/bin/shellcheck <<-EOOOF
	#!/bin/sh
	true
	EOOOF
chmod a+x /usr/local/bin/shellcheck
git clone https://github.com/jsarenik/lightning-auto-test
cd lightning-auto-test
export DEVELOPER=1
./run.sh
EOF

sudo ./chsys alpine sh /var/tmp/script

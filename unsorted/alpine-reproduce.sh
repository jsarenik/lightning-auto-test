#!/bin/sh

# requirements
type sudo tar wget

# see https://alpinelinux.org/downloads/ for more architectures,
# the rest are scripts and should work on all architectures
AMAC=x86_64
AVER=3.8.0
AURL="http://dl-cdn.alpinelinux.org/alpine/v${AVER%.*}/releases"
ALPINE="$AURL/$AMAC/alpine-minirootfs-$AVER-$AMAC.tar.gz"

MYCH=$HOME/chsys
mkdir $MYCH && cd $MYCH || exit 1
wget $ALPINE
wget https://raw.githubusercontent.com/jsarenik/dotfiles/master/bin/chsys
chmod a+x chsys

# Extract Alpine root
mkdir alpine
cd alpine
sudo tar xf ../${ALPINE##*/}
cd ..
sudo chmod a+rx alpine

# Script that is run inside chroot
cat >$MYCH/alpine/var/tmp/script <<EOF
apk update
apk upgrade
apk add git bitcoin libtool autoconf automake build-base python3-dev gmp-dev sqlite-dev zlib-dev cppcheck
#apk add db-c++ db boost db-dev boost-dev libressl-dev libevent-dev
cat > /usr/local/bin/shellcheck << EOOOF
#!/bin/sh
true
EOOOF
chmod a+x /usr/local/bin/shellcheck
git clone https://github.com/jsarenik/lightning-auto-test
cd lightning-auto-test
export DEVELOPER=0
./run.sh
EOF

sudo ./chsys alpine sh /var/tmp/script

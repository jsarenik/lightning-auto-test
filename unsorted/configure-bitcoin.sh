#!/bin/sh

export CFLAGS="-pipe -s -march=native -mtune=native -O3"

./configure \
  --without-gui \
  --with-incompatible-bdb \
  --disable-wallet \
  --disable-tests \
  --disable-bench \
  CFLAGS="$CFLAGS" \
  CXXFLAGS="$CFLAGS" \
  $*

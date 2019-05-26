#!/bin/sh

while true
  cd /tmp
  do ls -dt ltests-* | tee /tmp/olddirs | sed 2d | while read a
    do rm -rv $a
  done || exit 1

  DIR=$(head -1 /tmp/olddirs)
  test -n "$DIR" || exit 1
  cd $DIR
  exit 0
  ls -t > /tmp/oldtests
  wc -l /tmp/oldtests | while read n rest
    do test $n -gt 1 && sed 2d /tmp/oldtests | while read a;
      do rm -r $a
    done
  done
  true
  sleep 2
done

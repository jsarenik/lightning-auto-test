debootstrap --variant=buildd --arch=amd64 \
  bionic ./ubuntu-18 http://archive.ubuntu.com/ubuntu/

# now chsys into it...
# (see https://github.com/jsarenik/dotfiles/tree/master/bin/chsys)

printf 'deb http://archive.ubuntu.com/ubuntu %s main multiverse universe restricted\n' $(lsb_release -sc){,-security} > /etc/apt/sources.list

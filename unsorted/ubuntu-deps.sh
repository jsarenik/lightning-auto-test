APT=apt-get

. /etc/lsb-release
{
printf 'deb mirror://mirrors.ubuntu.com/mirrors.txt %s main multiverse universe restricted\n' $DISTRIB_CODENAME
printf 'deb mirror://mirrors.ubuntu.com/mirrors.txt %s main multiverse universe restricted\n' $DISTRIB_CODENAME-security
} | tee /etc/apt/sources.list

$APT update
$APT upgrade -y
$APT install -y busybox
ln -s busybox /bin/vi
$APT install -y tmux time git
$APT install -y build-essential libtool libgmp-dev autotools-dev automake pkg-config bsdmainutils libsqlite3-dev python3-dev python3-pip zlib1g-dev
$APT install -y libevent-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libsqlite3-dev
$APT install -y cppcheck shellcheck
#apt install -y asciidoc valgrind

APT=apt-get

. /etc/lsb-release
printf 'deb mirror://mirrors.ubuntu.com/mirrors.txt %s main multiverse universe restricted\n' $DISTRIB_CODENAME{,-security} > /etc/apt/sources.list

$APT update
$APT upgrade -y
$APT install -y tmux time git
$APT install -y autoconf automake build-essential libtool libgmp-dev libsqlite3-dev python3-dev python3-pip zlib1g-dev
$APT install -y software-properties-common
echo | add-apt-repository ppa:bitcoin/bitcoin
$APT update
$APT install -y bitcoind
$APT install -y cppcheck shellcheck
#apt install -y asciidoc valgrind

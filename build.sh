#!/bin/bash

repos="cligen clixon clixon-controller clixon-pyapi"
curdir=$(pwd)

usage() {
	echo "Usage: $0 [options]"
	echo "-b build packages"
	echo "-c clean up"
	echo "-u upload packages"
	exit
}

build() {
    # Install dependencies
    DEBIAN_FRONTEND=noninteractive sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt install -y git make gcc bison libnghttp2-dev libssl-dev flex build-essential python3 dh-python python3-stdeb python3-pip 

    # Create the user clicon if it does not exist
    grep clicon /etc/passwd > /dev/null

    if [ $? != 0 ]; then
	sudo useradd -r -s /bin/false clicon
    fi

    # Clone all repos
    for repo in ${repos}; do
	if [ -d "${repo}" ]; then
	    (cd "${repo}"; git pull)
	else
	    git clone "https://github.com/clicon/${repo}.git"
	fi

	if [ $? != 0 ]; then
	    echo "Git: ${repo} failed"
	    exit
	fi
    done

    # Build all repos
    for repo in $repos; do
	builddir="${curdir}/build/${repo}"

	if [ "$repo" != "clixon-pyapi" ]; then
	    sudo chown root:root "$builddir"
	fi

	if [ "$repo" == "cligen" ]; then
	    (cd "$repo"; ./configure --prefix="$builddir"; make; sudo make install)
	elif [ "$repo" == "clixon" ]; then
	    (cd "$repo"; ./configure --prefix="$builddir" --with-cligen="${curdir}/build/cligen"; make; sudo make install)
	elif [ "$repo" == "clixon-controller" ]; then
	    (cd "$repo"; ./configure --prefix="$builddir" --with-cligen="${curdir}/build/cligen" --with-clixon="${curdir}/build/clixon"; make; sudo make install)
	fi

	if [ "$repo" == "clixon-pyapi" ]; then
	    echo "Should build PyAPI here..."
	#    (cd "$repo"; ./requirements-apt.sh)
	#    (cd "$repo"; python3 setup.py --command-packages=stdeb.command bdist_deb)
	#    mv "${repo}/deb_dist/"*.deb "${curdir}/build"
	else
	    version=$($curdir/extract_version.sh "${repo}")
	    (cd "${curdir}/build/"; sed -ie "s/Version:.*/Version: $version/g" ${repo}/DEBIAN/control; sudo dpkg-deb --build ${repo})
	fi
    done
}

clean() {
    sudo rm -f ${curdir}/build/*.deb

    for repo in $repos; do
	# Remove all files under ${curdir}/build/${repo}
	if [ -d "${curdir}/build/${repo}" ]; then
	    (cd "${curdir}/build/${repo}"; sudo rm -rf bin etc include lib sbin share var local)
	fi

	# Do a make clean for all repos
	if [ -d "${repo}" ]; then
	    sudo rm -r ${repo}
	fi
    done
}

upload() {
    if [ -z ${API_USER} ]; then
	echo "API_USER must be set."
	exit
    fi

    if [ -z ${API_KEY} ]; then
	echo "API_KEY must be set."
	exit
    fi

    if [ -z ${API_URL} ]; then
	API_URL="https://platform.sunet.se/api/packages/khn/debian/pool/bookworm/main/upload"
    fi

    for package in build/*.deb; do
	curl --user ${API_USER}:${API_KEY} --upload-file $package ${API_URL}
    done
}

# If no arguments are given, then print usage
if [ $# -eq 0 ]; then
    usage
fi

while getopts "bcu" opt; do
    case $opt in
	    b)
	    build
	    ;;
	c)
	    clean
	    ;;
	u)
	    upload
	    ;;
	*)
	    usage
	    ;;
	esac
done

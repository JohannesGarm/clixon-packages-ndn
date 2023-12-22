#!/bin/bash

set -e

repos="cligen clixon clixon-controller clixon-pyapi"
curdir=$(pwd)

usage() {
	echo "Usage: $0 [options]"
	echo "-b build packages"
	echo "-c clean up"
	exit
}

build() {
    # Install dependencies
    sudo apt update
    sudo apt install -y git make gcc bison libnghttp2-dev libssl-dev flex build-essential python3

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
	    (cd "$repo"; ./configure --prefix="$builddir" --with-cligen="${builddir}/cligen"; make; sudo make install)
	elif [ "$repo" == "clixon-controller" ]; then
	    (cd "$repo"; ./configure --prefix="$builddir" --with-cligen="${builddir}/cligen" --with-clixon="${curdir}/build/clixon"; make; sudo make install)
	fi

	if [ "$repo" == "clixon-pyapi" ]; then
	    (cd "$repo"; ./requirements-apt.sh)
	    (cd "$repo"; python3 setup.py --command-packages=stdeb.command bdist_deb)
	    mv "${repo}/deb_dist/"*.deb "${curdir}/build"
	else
	    (cd "${curdir}/build/"; sed -ie "s/Version:.*/Version: `date +"%s"`/g" ${repo}/DEBIAN/control; sudo dpkg-deb --build ${repo})
	fi
    done
}

clean() {
    rm ${curdir}/build/*.deb
    
    for repo in $repos; do
	# Remove all files under ${curdir}/build/${repo}
	if [ -d "${curdir}/build/${repo}" ]; then
	    (cd "${curdir}/build/${repo}"; sudo rm -rf bin etc include lib sbin share var local)
	fi
	
	# Do a make clean for all repos
	if [ -d "${repo}" ]; then
	    (cd "${repo}"; sudo make clean)
	fi
    done
}

# If no arguments are given, then print usage
if [ $# -eq 0 ]; then
    usage
fi

while getopts "bc" opt; do
    case $opt in
	    b)
	    build
	    ;;
	c)
	    clean
	    ;;
	*)
	    usage
	    ;;
	esac
done

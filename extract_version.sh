#!/bin/sh


repo=$1

if [ -z "$repo" ]; then
	echo "Usage: $0 <repo>"
	exit 1
fi

if [ ! -d "$repo" ]; then
	echo "Repo $repo does not exist"
	exit 1
fi

repo="${repo%/}"
cd "$repo"


if [ $repo = "cligen" ]; then
    major=$(grep -oP '(?<=CLIGEN_VERSION_MAJOR=")\d+' configure.ac)
    minor=$(grep -oP '(?<=CLIGEN_VERSION_MINOR=")\d+' configure.ac)
    patch=$(grep -oP '(?<=CLIGEN_VERSION_PATCH=")\d+' configure.ac)
    version=$major.$minor.$patch
elif [ $repo = "clixon" ]; then
    major=$(grep -oP '(?<=CLIXON_VERSION_MAJOR=")\d+' configure.ac)
    minor=$(grep -oP '(?<=CLIXON_VERSION_MINOR=")\d+' configure.ac)
    patch=$(grep -oP '(?<=CLIXON_VERSION_PATCH=")\d+' configure.ac)
    version=$major.$minor.$patch    
elif [ $repo = "clixon-controller" ]; then
    major=$(grep -oP '(?<=CONTROLLER_VERSION_MAJOR=")\d+' configure.ac)
    minor=$(grep -oP '(?<=CONTROLLER_VERSION_MINOR=")\d+' configure.ac)
    patch=$(grep -oP '(?<=CONTROLLER_VERSION_PATCH=")\d+' configure.ac)
    version=$major.$minor.$patch
elif [ $repo = "clixon-pyapi" ]; then
    version=$(grep -oP '(?<=version=")\d+.\d+.\d+' setup.py)    
fi

echo $version

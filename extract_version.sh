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

version=$(git describe --tags --abbrev=0)

echo $version

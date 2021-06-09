#!/usr/bin/env bash
set -e

export HELM_VERSION=$1

if [ -z "${HELM_VERSION}" ]; then
    echo "Error: helm version is required as first argument"
    exit 1
fi
export DEB_PACKAGE=helm
export DEB_VERSION=${HELM_VERSION}-1

./build.sh
./test-deb.sh
./push.sh

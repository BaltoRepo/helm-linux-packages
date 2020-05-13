#!/usr/bin/env bash
# In a Docker container, install the package and run helm.
# Helm 3 exit code should be 0; Helm 2 exit code should be 1 because it hasn't been configured with a K8S cluster.
set -ex
if [ -z "$DEB_PACKAGE" ]; then
  echo "DEB_PACKAGE env variable is required and not set."
  exit 1
fi
if [ -z "$DEB_VERSION" ]; then
  echo "DEB_VERSION env variable is required and not set."
  exit 1
fi
ARCH=${ARCH:-amd64}
WD=$(pwd)/

PACKAGE="${DEB_PACKAGE}_${DEB_VERSION}_${ARCH}.deb"
docker container run \
  --rm \
  --env PACKAGE=${PACKAGE} \
  --mount type=bind,source=${WD},destination=/opt/,readonly \
  "debian:10" \
  bash /opt/deb-install-in-docker.sh

#!/usr/bin/env bash
# Push to Balto Repo
set -e
if [ -z "$DEB_VERSION" ]; then
  echo "DEB_VERSION env variable is required and not set."
  exit 1
fi
if [ -z "${PUSH_TOKEN}" ]; then
  echo "PUSH_TOKEN env variable is required and not set."
  exit 1
fi
if [[ "$DEB_VERSION" = 2* ]]; then
	PACKAGE_NAME=helm2
else
  # Default to Helm 3
  PACKAGE_NAME=helm
fi
REPO_UPLOAD=${REPO_UPLOAD:-https://helm.baltorepo.com/stable/debian/upload/}

function push {
  ARCH=$1

  curl \
    --verbose \
    --http1.1 \
    --progress-bar \
    --header "Authorization: Bearer ${PUSH_TOKEN}" \
    --form "package=@${PACKAGE_NAME}_${DEB_VERSION}_${ARCH}.deb" \
    --form "readme=<repo-readme.md" \
    --form distribution=all \
    "${REPO_UPLOAD}"
}

for ARCH in amd64 i386 armel arm64 ppc64el s390x; do
  push ${ARCH}
done

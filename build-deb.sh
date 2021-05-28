#!/usr/bin/env bash
# Build Debian packages for the given HELM_VERSION.
set -ex
if [ -z "$HELM_VERSION" ]; then
  echo "HELM_VERSION env variable is required and not set."
  exit 1
fi
if [[ "$HELM_VERSION" = 2* ]]; then
	PACKAGE_NAME=helm2
	PACKAGE_URL="https://v2.helm.sh/"
else
  # Default to Helm 3
  PACKAGE_NAME=helm
	PACKAGE_URL="https://helm.sh/"
fi
# Increment $DEB_REVISION every time you make a packaging change. Reset to 1 when $HELM_VERSION changes.
DEB_REVISION=${DEB_REVISION:-1}

function package_helm {
  ARCH=$1
  DOWNLOAD_ARCH=$ARCH
  if [ "${ARCH}" == "ppc64el" ]; then
    # Debian's arch ppc64el in Golang terms is ppc64le.
    DOWNLOAD_ARCH="ppc64le"
  elif [ "${ARCH}" == "armel" ]; then
    # Debian's arch armel in Golang terms is arm.
    DOWNLOAD_ARCH="arm"
  elif [ "${ARCH}" == "i386" ]; then
    # Debian's arch i386 in Golang terms is 386.
    DOWNLOAD_ARCH="386"
  fi
  if [[ "$HELM_VERSION" = 2* ]]; then
    TILLER_FPM="tmp/linux-${DOWNLOAD_ARCH}/tiller=/usr/bin/"
    TILLER_FPM_SYMLINK="tmp/symlinks/tiller=/usr/sbin/"
    DEB_DESCRIPTION="The package manager for Kubernetes (v2)"
    MANPAGE="tmp/manpages/helm2.gz"
  else
    # Default to Helm 3
    TILLER_FPM=""
    TILLER_FPM_SYMLINK=""
    DEB_DESCRIPTION="The package manager for Kubernetes"
    MANPAGE="tmp/manpages/helm.gz"
  fi

  curl "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${DOWNLOAD_ARCH}.tar.gz" --output tmp/helm.tar.gz

  tar -xzvf tmp/helm.tar.gz --directory tmp/

  rm -f ${PACKAGE_NAME}_${HELM_VERSION}-${DEB_REVISION}_${ARCH}.deb
  fpm \
    --input-type dir \
    --output-type deb \
    --name "${PACKAGE_NAME}" \
    --architecture "${ARCH}" \
    --version "${HELM_VERSION}-${DEB_REVISION}" \
    --maintainer 'Matt Fox <matt@getbalto.com>' \
    --url "${PACKAGE_URL}" \
    --description "${DEB_DESCRIPTION}" \
    tmp/linux-${DOWNLOAD_ARCH}/LICENSE=/usr/share/doc/${PACKAGE_NAME}/ \
    tmp/linux-${DOWNLOAD_ARCH}/helm=/usr/bin/ \
    tmp/symlinks/helm=/usr/sbin/ \
    ${MANPAGE}=/usr/share/man/man8/helm.gz ${TILLER_FPM} ${TILLER_FPM_SYMLINK}
}

rm -rf tmp/
mkdir -p tmp/
cp -r manpages tmp/
gzip tmp/manpages/*
# Make symlinks that live in old location; see https://github.com/BaltoRepo/helm-linux-packages/issues/1
mkdir -p tmp/symlinks
ln -sf /usr/bin/helm tmp/symlinks/helm
ln -sf /usr/bin/tiller tmp/symlinks/tiller

for ARCH in amd64 i386 armel arm64 ppc64el s390x; do
  package_helm ${ARCH}
done

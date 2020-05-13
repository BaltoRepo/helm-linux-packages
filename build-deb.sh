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
  if [ "${DOWNLOAD_ARCH}" == "ppc64el" ]; then
    # Golang has arch ppc64le while Debian calls it ppc64el.
    DOWNLOAD_ARCH="ppc64le"
  elif [ "${DOWNLOAD_ARCH}" == "armel" ]; then
    # Golang has arch arm while Debian calls it armel.
    DOWNLOAD_ARCH="arm"
  elif [ "${DOWNLOAD_ARCH}" == "i386" ]; then
    # Golang has arch 386 while Debian calls it i386.
    DOWNLOAD_ARCH="386"
  fi
  if [[ "$HELM_VERSION" = 2* ]]; then
    TILLER_FPM="tmp/linux-${DOWNLOAD_ARCH}/tiller=/usr/sbin/"
    DEB_DESCRIPTION="The package manager for Kubernetes (v2)"
    MANPAGE="tmp/manpages/helm2.gz"
  else
    # Default to Helm 3
    TILLER_FPM=""
    DEB_DESCRIPTION="The package manager for Kubernetes"
    MANPAGE="tmp/manpages/helm.gz"
  fi

  curl "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${DOWNLOAD_ARCH}.tar.gz" --output tmp/helm.tar.gz

  tar -xzvf tmp/helm.tar.gz --directory tmp/

  rm -f ${PACKAGE_NAME}_${HELM_VERSION}-${DEB_REVISION}_${ARCH}.deb
  fpm \
    -s dir \
    -t deb \
    -n "${PACKAGE_NAME}" \
    -a "${ARCH}" \
    -v "${HELM_VERSION}-${DEB_REVISION}" \
    --maintainer 'Matt Fox <matt@getbalto.com>' \
    --url "${PACKAGE_URL}" \
    --description "${DEB_DESCRIPTION}" \
    tmp/linux-${DOWNLOAD_ARCH}/LICENSE=/usr/share/doc/${PACKAGE_NAME}/ \
    tmp/linux-${DOWNLOAD_ARCH}/helm=/usr/sbin/ \
    ${MANPAGE}=/usr/share/man/man8/ ${TILLER_FPM}
}

rm -rf tmp/
mkdir -p tmp/
cp -r manpages tmp/
gzip tmp/manpages/*

for ARCH in amd64 i386 armel arm64 ppc64el s390x; do
  package_helm ${ARCH}
done

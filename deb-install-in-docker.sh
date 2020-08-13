#!/usr/bin/env bash
set -ex
if [ -z "$PACKAGE" ]; then
  echo "PACKAGE env variable is required and not set."
  exit 1
fi

dpkg -i /opt/${PACKAGE}
/usr/sbin/helm version  # This is a symlink; supported for backwards compatibility
/usr/bin/helm version

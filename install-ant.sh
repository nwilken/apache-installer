#!/usr/bin/env sh
set -e

#
# Installs the given Apache tool, verifying checksums and GPG signatures. Exits
# non-zero on failure.
#
# Usage:
#   install-ant.sh 1.10.7
#
# Requirements:
#   - curl
#   - gpg


VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "Missing VERSION"
  exit
fi

DOWNLOAD_ROOT="https://www.apache.org/dist/ant"
DOWNLOAD_BIN="apache-ant-${VERSION}-bin.tar.gz"
DOWNLOAD_SIG="apache-ant-${VERSION}-bin.tar.gz.asc"

echo "==> Installing ant v${VERSION}"

echo "--> Importing keys"
curl -sSL "${DOWNLOAD_ROOT}/KEYS" | gpg --import
gpg --fingerprint | grep fingerprint | tr -d '[:blank:]' | awk 'BEGIN {FS="="} {print $2 ":6:"}' | gpg --import-ownertrust

echo "--> Downloading ant v${VERSION}"
curl -sfSO "${DOWNLOAD_ROOT}/binaries/${DOWNLOAD_BIN}"
curl -sfSO "${DOWNLOAD_ROOT}/binaries/${DOWNLOAD_SIG}"

echo "--> Verifying signatures file"
gpg --batch --verify "${DOWNLOAD_SIG}" "${DOWNLOAD_BIN}"

echo "--> Unpacking and installing"
mkdir -p /software
tar xvfz "${DOWNLOAD_BIN}" --directory /software

echo "--> Removing temporary files"
rm "${DOWNLOAD_BIN}"
rm "${DOWNLOAD_SIG}"

echo "--> Done!"

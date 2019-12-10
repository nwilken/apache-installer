#!/usr/bin/env sh
set -e

#
# Installs the given Apache tool, verifying checksums and GPG signatures. Exits
# non-zero on failure.
#
# Usage:
#   install-tomcat.sh 7.0.96
#
# Requirements:
#   - curl
#   - gpg


VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "Missing VERSION"
  exit
fi

MAJOR_VERSION=$(echo $VERSION | awk 'BEGIN {FS="."} {print $1}')

if [ "$MAJOR_VERSION" -gt 6 ]; then DOWNLOAD_HOST="www.apache.org"; else DOWNLOAD_HOST="archive.apache.org"; fi

#
# for v7 and above, use www.apache.org to force the latest version
#
DOWNLOAD_HOST=$([ "$MAJOR_VERSION" -ge 7 ] && echo "www.apache.org" || echo "archive.apache.org")
DOWNLOAD_ROOT="https://${DOWNLOAD_HOST}/dist/tomcat/tomcat-${MAJOR_VERSION}/v${VERSION}"
DOWNLOAD_BIN="apache-tomcat-${VERSION}.tar.gz"
DOWNLOAD_SIG="apache-tomcat-${VERSION}.tar.gz.asc"

echo "==> Installing tomcat v${VERSION}"

echo "--> Importing keys"
curl -sSL "${DOWNLOAD_ROOT}/KEYS" | gpg --import
gpg --fingerprint | grep fingerprint | tr -d '[:blank:]' | awk 'BEGIN {FS="="} {print $2 ":6:"}' | gpg --import-ownertrust

echo "--> Downloading tomcat v${VERSION}"
curl -sfSO "${DOWNLOAD_ROOT}/bin/${DOWNLOAD_BIN}"
curl -sfSO "${DOWNLOAD_ROOT}/bin/${DOWNLOAD_SIG}"

echo "--> Verifying signatures file"
gpg --batch --verify "${DOWNLOAD_SIG}" "${DOWNLOAD_BIN}"

echo "--> Unpacking and installing"
mkdir -p /software
tar xvfz "${DOWNLOAD_BIN}" --directory /software

echo "--> Removing temporary files"
rm "${DOWNLOAD_BIN}"
rm "${DOWNLOAD_SIG}"

echo "--> Done!"

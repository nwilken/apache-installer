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

DOWNLOAD_ROOT="https://www.apache.org/dist/tomcat/tomcat-${MAJOR_VERSION}/v${VERSION}"
DOWNLOAD_BIN="apache-tomcat-${VERSION}.zip"
DOWNLOAD_SIG="apache-tomcat-${VERSION}.zip.asc"

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
unzip -d "/software" "${DOWNLOAD_BIN}"

echo "--> Removing temporary files"
rm "${DOWNLOAD_BIN}"
rm "${DOWNLOAD_SIG}"

echo "--> Done!"

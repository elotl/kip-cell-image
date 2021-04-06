#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:-}"
if [[ $VERSION =~ ^v[0-9].* ]]; then
    VERSION=""${VERSION#v}""
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PKG_DIR=$SCRIPT_DIR/kip-cell
cd $PKG_DIR

# Download the latest release of itzo-launcher, tosi, itzo and kube-router.
# TODO: revert changing to arm, use a env variable to get correct url
curl -fsL https://itzo-dev-download.s3.amazonaws.com/itzo-launcher-arm > itzo-launcher && chmod 755 itzo-launcher

curl -fsL https://itzo-dev-download.s3.amazonaws.com/tosi-arm > tosi && chmod 755 tosi

curl -fsL https://itzo-dev-download.s3.amazonaws.com/itzo-arm > itzo && chmod 755 itzo

curl -fsL https://itzo-dev-download.s3.amazonaws.com/kube-router-arm > kube-router && chmod 755 kube-router

# Build deb package.
export DEBFULLNAME="Elotl Maintainers"
export DEBEMAIL="info@elotl.co"

MSG="New upstream release"
if [[ "$VERSION" = "" ]]; then
    debchange --increment "$MSG"
else
    debchange --newversion "$VERSION" "$MSG"
fi
debchange --release "$MSG"

debuild -i -us -uc -b

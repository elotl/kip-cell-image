#!/usr/bin/env bash

set -euo pipefail

VERSION="${VERSION:-}"
if [[ $VERSION =~ ^v[0-9].* ]]; then
    VERSION=""${VERSION#v}""
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PKG_DIR=$SCRIPT_DIR/kip-cell
cd $PKG_DIR

ITZO_LAUNCHER_VERSION="v0.0.4"
curl -fsL https://github.com/elotl/itzo-launcher/releases/download/$ITZO_LAUNCHER_VERSION/itzo-launcher-amd64 > itzo-launcher && chmod 755 itzo-launcher

TOSI_VERSION="v0.0.3"
curl -fsL https://github.com/elotl/tosi/releases/download/$TOSI_VERSION/tosi-amd64 > tosi && chmod 755 tosi

curl -fsL http://itzo-dev-download.s3.amazonaws.com/itzo-latest > itzo && chmod 755 itzo

curl -fsL http://itzo-dev-download.s3.amazonaws.com/kube-router > kube-router && chmod 755 kube-router

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

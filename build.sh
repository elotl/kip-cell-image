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
curl -fsL $(curl -s https://api.github.com/repos/elotl/itzo-launcher/releases/latest | jq -r '.assets[].browser_download_url' | head -n1) > itzo-launcher && chmod 755 itzo-launcher

curl -fsL $(curl -s https://api.github.com/repos/elotl/tosi/releases/latest | jq -r '.assets[].browser_download_url' | head -n1) > tosi && chmod 755 tosi

curl -fsL https://itzo-kip-download.s3.amazonaws.com/itzo-latest > itzo && chmod 755 itzo

curl -fsL https://itzo-dev-download.s3.amazonaws.com/kube-router-v1.3.0-rc2-34-gd173c988-dirty > kube-router && chmod 755 kube-router

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

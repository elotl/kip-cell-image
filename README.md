# kip-cell-deb

Debian package for installing components required on a Kip cell image.

## Usage

To build a debian package with itzo-launcher, tosi and kube-router:

    $ ./build.sh

This will create a package in the current directory.

You can specify a version number for the build:

    $ VERSION=v0.1.2-foo1 ./build.sh
    [...]
    $ ls -1 kip-cell_*_amd64.deb
    kip-cell_0.1.2-foo1_amd64.deb

Using the .deb package, you can also build an AWS and GCP image:

    $ VERSION=v0.1.2-foo1 ./build.sh
    [...]
    # Configure your GCE and AWS access.
    $ export GOOGLE_CLOUD_KEYFILE_JSON=/home/vilmos/<my-gce-account-file>.json
    $ export AWS_ACCESS_KEY_ID=...
    $ export AWS_SECRET_ACCESS_KEY=...
    $ packer build -var package=kip-cell_${VERSION:1}_amd64.deb packer.json

This needs [packer](https://www.packer.io/).

## Automated builds

A GitHub Action is configured to build images automatically for every version tag pushed:

    $ git tag -am "v0.1.2-foo1" v0.1.2-foo1
    $ git push --tags

This image will be called `elotl-kipdev-v0.1.2-foo1` on AWS, and `elotl-kipdev-v0-1-2-foo1` on GCE.

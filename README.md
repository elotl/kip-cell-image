# Debian package and scripts for building Kip cell images

Debian package for installing components required on a [Kip](https://github.com/elotl/kip) cell image. Images using the package are also built automatically for every change.

## Usage

[Kip cells](https://github.com/elotl/kip/blob/master/docs/cells.md) are cloud VM instances that run pods. Kip uses pre-built images for cells. There are a couple of software components needed on a cell image so that Kip can run pods on it:
* [itzo](https://github.com/elotl/itzo), the cell agent,
* [tosi](https://github.com/elotl/tosi), for pulling container images for pods and
* [kube-router](https://github.com/cloudnativelabs/kube-router), the network agent acting as a Kubernetes service proxy and Kubernetes network policy agent.

To build a debian package with all these components:

    ./build.sh

This will create a package in the current directory.

You can specify a version number for the build:

    VERSION=v0.1.2-foo1 ./build.sh
    [...]
    ls -1 kip-cell_*_amd64.deb
    kip-cell_0.1.2-foo1_amd64.deb

You can take this debian package and install it on your own image if you would like to create an image that can boot up as a Kip cell.

Using the .deb package, you can also build an AWS and GCP image:

    VERSION=v0.1.2-foo1 ./build.sh
    [...]
    # Configure your GCE and AWS access.
    export GOOGLE_CLOUD_KEYFILE_JSON=/home/ubuntu/<my-gce-account-file>.json
    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    packer build -var package=kip-cell_${VERSION:1}_amd64.deb packer.json

This needs [packer](https://www.packer.io/).

## Automated builds

A GitHub Action is configured to build images automatically for every push. The image name is based on `git describe`. For example:

    git tag -am "v0.1.2-foo1" v0.1.2-foo1
    git push --tags

The resulting image in this case will be called `elotl-kipdev-v0.1.2-foo1` on AWS, and `elotl-kipdev-v0-1-2-foo1` on GCE.

Git tags with a semantic version like `v1.2.3` will update `elotl-kip-latest` on GCE (since on GCE, Kip uses this fixed image name by default), and create a new `elotl-kip-<version>` image on AWS (on AWS, by the default the latest `elotl-kip-*` is used by kip).

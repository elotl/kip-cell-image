# kip-cell-deb

Debian package for installing components required on a Kip cell image. Images using the package are also built automatically for every change.

## Usage

[Kip cells](https://github.com/elotl/kip/blob/master/docs/cells.md) are cloud VM instances that run pods. Kip uses pre-built images for cells. There are a couple of software components needed on a cell image so that Kip can run pods on it:
* [itzo](https://github.com/elotl/itzo), the cell agent,
* [tosi](https://github.com/elotl/tosi), for pulling container images for pods and
* [kube-router](https://github.com/cloudnativelabs/kube-router), the network agent acting as a Kubernetes service proxy and Kubernetes network policy agent.

To build a debian package with all these components:

    $ ./build.sh

This will create a package in the current directory.

You can specify a version number for the build:

    $ VERSION=v0.1.2-foo1 ./build.sh
    [...]
    $ ls -1 kip-cell_*_amd64.deb
    kip-cell_0.1.2-foo1_amd64.deb

You can take this debian package and install it on your own image if you would like to create an image that can boot up as a Kip cell.

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

A GitHub Action is configured to build images automatically for every push. The image name is based on `git describe`. For example:

    $ git tag -am "v0.1.2-foo1" v0.1.2-foo1
    $ git push --tags

The resulting image in this case will be called `elotl-kipdev-v0.1.2-foo1` on AWS, and `elotl-kipdev-v0-1-2-foo1` on GCE.

Git tags with a semantic version will update the `elotl-kipdev-latest` image with that build.

## Update elotl-kip-latest

The image `elotl-kip-latest` is the default one in Kip. It is not updated automatically. To update it manually on GCE, you can use this script:

    gcloud compute --quiet --project elotl-kip images delete \
        elotl-kip-latest
    gcloud compute --quiet --project elotl-kip images create \
        --source-image=elotl-kipdev-latest \
        elotl-kip-latest
    gcloud compute --quiet --project elotl-kip images add-iam-policy-binding \
        elotl-kip-latest \
        --member=allAuthenticatedUsers \
        --role='roles/compute.imageUser'

On AWS:

    AWS_REGION=us-east-1
    image_id=$(aws ec2 describe-images \
        --region ${AWS_REGION} \
        --filters Name=name,Values=elotl-kipdev-latest | \
        jq -r '.Images[0].ImageId')
    aws ec2 copy-image \
        --name elotl-kipdev-latest \
        --source-image-id ${image_id} \
        --source-region ${AWS_REGION}

#!/usr/bin/env bash
set -e

build_dir=$1
dst_dir=$2
channel=$3

data_img="${dst_dir}/data.ext4"

# Make image
rm -f "${data_img}"
truncate --size="1280M" "${data_img}"
mkfs.ext4 -L "hassos-data" -E lazy_itable_init=0,lazy_journal_init=0 "${data_img}"

# Mount / init file structs
mkdir -p "${build_dir}/data/"
sudo mount -o loop,discard "${data_img}" "${build_dir}/data/"

# Use official Docker in Docker images
# Ideally we use the same version as Buildroot is using in case the
# overlayfs2 storage format changes
# Add more storage space and better storage driver options
container=$(docker run --privileged -e DOCKER_TLS_CERTDIR="" \
	-v "${build_dir}/data/":/data \
	-v "${build_dir}/data/docker/":/var/lib/docker \
	-v "${build_dir}":/build \
	--storage-opt size=10G \
	-d docker:28.0-dind --storage-driver overlay2 --storage-opt overlay2.size=10G)

docker exec "${container}" sh /build/dind-import-containers.sh "${channel}"

docker stop "${container}"

# Unmount data image
sudo umount "${build_dir}/data/"

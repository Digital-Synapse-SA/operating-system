#!/bin/sh
set -e

channel=$1

APPARMOR_URL="https://version.home-assistant.io/apparmor.txt"

# Make sure we can talk to the Docker daemon
echo "Waiting for Docker daemon..."
while ! docker version 2> /dev/null > /dev/null; do
	sleep 1
done

# Check available space before loading images
echo "Checking available space..."
available_space=$(df /var/lib/docker | awk 'NR==2 {print $4}')
if [ "$available_space" -lt 5000000 ]; then
	echo "Warning: Low disk space available ($available_space KB). Cleaning up..."
	docker system prune -a -f > /dev/null 2>&1 || true
fi

# Install Supervisor, plug-ins and landing page
echo "Loading container images..."

# Load images in smaller batches to manage space better
echo "Loading container images in batches..."

# Get list of images and sort by size (smallest first to avoid space issues)
image_list=$(ls -S -r /build/images/*.tar)
total_images=$(echo "$image_list" | wc -l)
current=0

for image in $image_list; do
	current=$((current + 1))
	echo "Loading $(basename "${image}")... ($current/$total_images)"
	
	# Check space before loading
	available_space=$(df /var/lib/docker | awk 'NR==2 {print $4}')
	if [ "$available_space" -lt 1000000 ]; then
		echo "Low space detected ($available_space KB). Cleaning up..."
		docker system prune -f > /dev/null 2>&1 || true
		sleep 2
	fi
	
	# Load the image
	if ! docker load --input "${image}"; then
		echo "Failed to load $(basename "${image}"). Cleaning up and retrying..."
		docker system prune -f > /dev/null 2>&1 || true
		sleep 3
		docker load --input "${image}"
	fi
	
	# Clean up after each image
	docker system prune -f > /dev/null 2>&1 || true
	sleep 1
done

# Tag the Supervisor how the OS expects it to be tagged
supervisor=$(docker images --filter "label=io.hass.type=supervisor" --quiet)
arch=$(docker inspect --format '{{ index .Config.Labels "io.hass.arch" }}' "${supervisor}")
docker tag "${supervisor}" "ghcr.io/home-assistant/${arch}-hassio-supervisor:latest"

# Setup AppArmor
mkdir -p "/data/supervisor/apparmor"
wget -O "/data/supervisor/apparmor/hassio-supervisor" "${APPARMOR_URL}"

echo "{ \"channel\": \"${channel}\" }" > /data/supervisor/updater.json

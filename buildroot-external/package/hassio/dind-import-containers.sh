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

# Load images one by one with space management
# shellcheck disable=SC2045
for image in $(ls /build/images/*.tar); do
	echo "Loading $(basename "${image}")..."
	docker load --input "${image}"
	
	# Clean up intermediate layers to save space
	docker system prune -f > /dev/null 2>&1 || true
	
	# Small delay to allow filesystem to settle
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

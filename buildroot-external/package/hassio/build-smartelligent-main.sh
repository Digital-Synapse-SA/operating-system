#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Script to build main Smartelligent containers from Digital-Synapse-SA repositories
# Supporting containers (dns, audio, cli, multicast, observer) use standard versions

CORE_REPO="$1"
FRONTEND_REPO="$2"
SUPERVISOR_REPO="$3"
IMAGES_DIR="$4"
DL_DIR="$5"

BUILD_DIR="/tmp/smartelligent-main-build"
CACHE_DIR="$DL_DIR/smartelligent-cache"

echo "Building main Smartelligent containers from Digital-Synapse-SA repositories..."
echo "Supporting containers (dns, audio, cli, multicast, observer) will use standard versions."

# Create build directories
mkdir -p "$BUILD_DIR"
mkdir -p "$CACHE_DIR"
mkdir -p "$IMAGES_DIR"

# Function to build container from repository
build_container() {
    local repo_url="$1"
    local container_name="$2"
    
    echo "Building $container_name from $repo_url..."
    
    # Clone or update repository
    if [ ! -d "$BUILD_DIR/$container_name" ]; then
        git clone "$repo_url" "$BUILD_DIR/$container_name"
    else
        cd "$BUILD_DIR/$container_name"
        git pull origin main
        cd - > /dev/null
    fi
    
    # Build container
    cd "$BUILD_DIR/$container_name"
    
    # Special handling for frontend (needs build step)
    if [ "$container_name" = "frontend" ]; then
        echo "Building frontend assets..."
        if command -v yarn > /dev/null; then
            yarn install --frozen-lockfile
            yarn build
        else
            echo "Warning: yarn not found, skipping frontend build"
        fi
    fi
    
    # Build Docker image
    docker build -t "smartelligent/$container_name:latest" .
    
    # Save to tar file
    local tar_file="$IMAGES_DIR/smartelligent-$container_name.tar"
    docker save "smartelligent/$container_name:latest" > "$tar_file"
    
    echo "Saved $container_name to $tar_file"
    cd - > /dev/null
}

# Build main Smartelligent containers
build_container "$CORE_REPO" "core"
build_container "$FRONTEND_REPO" "frontend"
build_container "$SUPERVISOR_REPO" "supervisor"

echo "Main Smartelligent containers built successfully!"
echo "Container images saved in: $IMAGES_DIR"
echo ""
echo "Note: Supporting containers (dns, audio, cli, multicast, observer)"
echo "will be fetched from the official Home Assistant registry." 
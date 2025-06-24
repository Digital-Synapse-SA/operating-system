#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Configuration
CORE_REPO="https://github.com/Digital-Synapse-SA/core.git"
FRONTEND_REPO="https://github.com/Digital-Synapse-SA/frontend.git"
CORE_BRANCH="ST-Branding-Stage1"
FRONTEND_BRANCH="ST-Branding-Stage1"
BUILD_DIR="$1"
ARCH="$2"
MACHINE="$3"

echo "Building custom Smartelligent Home Assistant..."

# Create build directories
mkdir -p "${BUILD_DIR}/custom-core"
mkdir -p "${BUILD_DIR}/custom-frontend"

# Clone and build Core
echo "Building custom Core..."
cd "${BUILD_DIR}/custom-core"
if [ ! -d ".git" ]; then
    git clone --depth 1 --branch "${CORE_BRANCH}" "${CORE_REPO}" .
fi

# Build Core Docker image
docker build -t smartelligent/core:latest .

# Clone and build Frontend
echo "Building custom Frontend..."
cd "${BUILD_DIR}/custom-frontend"
if [ ! -d ".git" ]; then
    git clone --depth 1 --branch "${FRONTEND_BRANCH}" "${FRONTEND_REPO}" .
fi

# Build Frontend
npm ci
npm run build

# Create custom Core image with built Frontend
cd "${BUILD_DIR}/custom-core"
# Copy built frontend to core
cp -r "${BUILD_DIR}/custom-frontend/dist" ./frontend_dist

# Build final Core image with custom frontend
docker build -t smartelligent/core:latest --build-arg FRONTEND_DIR=./frontend_dist .

# Save the custom image
docker save smartelligent/core:latest | gzip > "${BUILD_DIR}/images/smartelligent_core_latest.tar.gz"

echo "Custom Smartelligent Home Assistant built successfully!" 
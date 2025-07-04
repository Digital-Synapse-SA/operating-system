#!/bin/bash
set -e

echo "🚀 Starting Smartelligent Home (Rebranded Home Assistant) Build"
echo "==============================================="

# Configuration
CUSTOM_REGISTRY="${CUSTOM_REGISTRY:-ghcr.io/digital-synapse-sa}"
CUSTOM_CORE_TAG="${CUSTOM_CORE_TAG:-2025.6.0-rebranded}"
CUSTOM_MACHINE="${CUSTOM_MACHINE:-generic-x86-64}"
CUSTOM_ARCH="${CUSTOM_ARCH:-amd64}"
BUILD_TARGET="${BUILD_TARGET:-custom-generic_x86_64}"
BRANCH_NAME="${BRANCH_NAME:-dev-04072025}"

echo "📋 Build Configuration:"
echo "  - Registry: $CUSTOM_REGISTRY"
echo "  - Core Tag: $CUSTOM_CORE_TAG"
echo "  - Machine: $CUSTOM_MACHINE"
echo "  - Architecture: $CUSTOM_ARCH"
echo "  - Target: $BUILD_TARGET"
echo "  - Branch: $BRANCH_NAME"
echo ""

# Check if we're building containers or just the OS
if [ "$1" = "containers" ]; then
    echo "🐳 Building Custom Container Images"
    echo "=================================="
    
    # Build custom frontend
    echo "Building rebranded frontend..."
    cd frontend
    
    # Checkout the correct branch
    echo "Checking out branch: $BRANCH_NAME"
    git checkout "$BRANCH_NAME" || echo "Warning: Branch $BRANCH_NAME not found, using current branch"
    
    # Apply rebranding patches
    echo "Applying rebranding patches..."
    
    # Replace translation files
    if [ -f "src/translations/en-rebranded.json" ]; then
        cp src/translations/en-rebranded.json src/translations/en.json
        echo "✅ Applied rebranded translations"
    fi
    
    # Replace HTML templates
    if [ -f "src/html/index-rebranded.html.template" ]; then
        cp src/html/index-rebranded.html.template src/html/index.html.template
        echo "✅ Applied rebranded HTML template"
    fi
    
    # Replace panel title mixin
    if [ -f "src/state/panel-title-mixin-rebranded.ts" ]; then
        cp src/state/panel-title-mixin-rebranded.ts src/state/panel-title-mixin.ts
        echo "✅ Applied rebranded panel title mixin"
    fi
    
    # Build frontend
    echo "Building frontend..."
    npm install
    npm run build
    
    cd ..
    
    echo "✅ Frontend build completed!"
    echo ""
    echo "🐳 Building Core Container Image"
    echo "==============================="
    
    # Build custom core container
    cd core
    
    # Checkout the correct branch
    echo "Checking out branch: $BRANCH_NAME"
    git checkout "$BRANCH_NAME" || echo "Warning: Branch $BRANCH_NAME not found, using current branch"
    
    # Copy the rebranded frontend build
    if [ -d "../frontend/build" ]; then
        rm -rf homeassistant/components/frontend/www_static
        cp -r ../frontend/build homeassistant/components/frontend/www_static
        echo "✅ Copied rebranded frontend to core"
    fi
    
    # Build core container
    echo "Building core container image..."
    docker build -t "${CUSTOM_REGISTRY}/${CUSTOM_MACHINE}-homeassistant:${CUSTOM_CORE_TAG}" .
    
    echo "✅ Core container build completed!"
    echo ""
    echo "📤 Push container to registry (optional):"
    echo "docker push ${CUSTOM_REGISTRY}/${CUSTOM_MACHINE}-homeassistant:${CUSTOM_CORE_TAG}"
    
    cd ..
    
elif [ "$1" = "os" ]; then
    echo "🖥️  Building Operating System Image"
    echo "================================="
    
    # Checkout the correct branch for operating system
    echo "Checking out branch: $BRANCH_NAME"
    git checkout "$BRANCH_NAME" || echo "Warning: Branch $BRANCH_NAME not found, using current branch"
    
    # Export configuration for build
    export HASSIO_CUSTOM_REGISTRY="$CUSTOM_REGISTRY"
    export HASSIO_CUSTOM_CORE_IMAGE="${CUSTOM_MACHINE}-homeassistant"
    export HASSIO_CUSTOM_CORE_TAG="$CUSTOM_CORE_TAG"
    
    # Build the OS
    echo "Building operating system with custom containers..."
    make "$BUILD_TARGET"
    
    echo "✅ Operating system build completed!"
    echo ""
    echo "📄 Build artifacts are in: output/images/"
    echo "🎯 Main image: output/images/generic-x86-64.img"
    
else
    echo "Usage: $0 [containers|os]"
    echo ""
    echo "Commands:"
    echo "  containers  - Build custom frontend and core container images"
    echo "  os          - Build the operating system image with custom containers"
    echo ""
    echo "Environment Variables:"
    echo "  CUSTOM_REGISTRY   - Container registry (default: ghcr.io/digital-synapse-sa)"
    echo "  CUSTOM_CORE_TAG   - Core container tag (default: 2025.7.0-rebranded)"
    echo "  CUSTOM_MACHINE    - Machine type (default: generic-x86-64)"
    echo "  CUSTOM_ARCH       - Architecture (default: amd64)"
    echo "  BUILD_TARGET      - Build target (default: custom-generic_x86_64)"
    echo "  BRANCH_NAME       - Git branch (default: dev-04072025)"
    echo ""
    echo "Example full build process:"
    echo "  1. ./scripts/build-rebranded.sh containers"
    echo "  2. docker push ghcr.io/digital-synapse-sa/generic-x86-64-homeassistant:2025.7.0-rebranded"
    echo "  3. ./scripts/build-rebranded.sh os"
fi

echo ""
echo "✨ Build process completed!" 
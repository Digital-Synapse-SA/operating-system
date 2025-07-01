#!/usr/bin/env bash

set -e

# Test script to verify Docker build environment
echo "Testing Docker build environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not accessible"
    exit 1
fi

echo "✅ Docker is running"

# Check if required base images are available
echo "Checking required base images..."

# Test Home Assistant base image
if docker pull ghcr.io/home-assistant/amd64-base:3.19 > /dev/null 2>&1; then
    echo "✅ Home Assistant base image is available"
else
    echo "⚠️  Home Assistant base image not available, will use fallback"
fi

# Test Alpine base image
if docker pull alpine:3.18 > /dev/null 2>&1; then
    echo "✅ Alpine base image is available"
else
    echo "❌ Alpine base image not available"
    exit 1
fi

# Test simple Docker build
echo "Testing simple Docker build..."
cat > /tmp/test-dockerfile << 'EOF'
FROM alpine:3.18
RUN echo "Test build successful"
CMD ["echo", "Hello from test container"]
EOF

if docker build -t test-smartelligent:latest /tmp/test-dockerfile > /dev/null 2>&1; then
    echo "✅ Simple Docker build works"
    docker rmi test-smartelligent:latest > /dev/null 2>&1 || true
else
    echo "❌ Simple Docker build failed"
    exit 1
fi

# Test build with build args
echo "Testing Docker build with build args..."
cat > /tmp/test-dockerfile-args << 'EOF'
ARG BUILD_FROM
FROM ${BUILD_FROM:-alpine:3.18}
RUN echo "Test build with args successful"
CMD ["echo", "Hello from test container with args"]
EOF

if docker build --build-arg BUILD_FROM=alpine:3.18 -t test-smartelligent-args:latest /tmp/test-dockerfile-args > /dev/null 2>&1; then
    echo "✅ Docker build with args works"
    docker rmi test-smartelligent-args:latest > /dev/null 2>&1 || true
else
    echo "❌ Docker build with args failed"
    exit 1
fi

# Cleanup
rm -f /tmp/test-dockerfile /tmp/test-dockerfile-args

echo ""
echo "🎉 Docker build environment test passed!"
echo "The build environment is ready for Smartelligent container builds." 
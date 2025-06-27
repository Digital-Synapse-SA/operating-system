#!/bin/bash
set -e

echo "Building Smartelligent Frontend..."
echo "=================================="

# Check if we're in the right directory
if [ ! -f "../frontend/package.json" ]; then
    echo "Error: Please run this script from the operating-system directory"
    exit 1
fi

# Navigate to frontend directory
cd ../frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    yarn install
fi

# Build the frontend
echo "Building Smartelligent frontend..."
yarn build

echo ""
echo "Frontend build completed successfully!"
echo "The rebranded frontend is now ready for deployment." 
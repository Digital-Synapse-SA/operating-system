#!/bin/bash

# Smartelligent Build Script
# This script builds a rebranded Home Assistant OS image called "Smartelligent"

set -e

echo "🚀 Starting Smartelligent build process..."
echo "📋 Building for generic Intel x86_64 architecture"
echo "🏢 Organization: Digital-Synapse-SA"
echo ""

# Check if we're in the right directory
if [ ! -f "scripts/enter.sh" ]; then
    echo "❌ Error: Please run this script from the operating-system directory"
    exit 1
fi

# Check if we're on the right branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "dev-27062025" ]; then
    echo "⚠️  Warning: You're not on the dev-27062025 branch (current: $CURRENT_BRANCH)"
    echo "   Consider switching to the correct branch for Smartelligent development"
    echo ""
fi

# Enter the build environment and build the image
echo "🔧 Entering build environment..."
echo "📦 Building Smartelligent x86_64 image..."
echo ""

# Use the enter.sh script to build the smartelligent_x86_64 target
./scripts/enter.sh make smartelligent_x86_64

echo ""
echo "✅ Smartelligent build completed!"
echo "📁 Output files should be in the output/ directory"
echo "🖼️  Look for files with 'smartelligent' in the name"
echo ""
echo "🎉 Your Smartelligent rebranded Home Assistant OS is ready!" 
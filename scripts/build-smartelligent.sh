#!/usr/bin/env bash

set -e
set -u

# Smartelligent OS Build Script
# This script allows you to build Smartelligent OS with different container configurations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HASSIO_PKG_DIR="$SCRIPT_DIR/../buildroot-external/package/hassio"

# Available configurations
CONFIGS=(
    "default"      # Default configuration (main components custom, supporting standard)
    "full"         # All containers custom
    "hybrid"       # Main components custom, supporting components standard
    "selective"    # Selective customization
)

# Function to show usage
show_usage() {
    echo "Smartelligent OS Build Script"
    echo ""
    echo "Usage: $0 [CONFIG] [BUILD_TARGET]"
    echo ""
    echo "CONFIG options:"
    for config in "${CONFIGS[@]}"; do
        case "$config" in
            "default")
                echo "  default    - Main components custom, supporting components standard"
                ;;
            "full")
                echo "  full       - All containers custom (maximum customization)"
                ;;
            "hybrid")
                echo "  hybrid     - Main components custom, supporting components standard"
                ;;
            "selective")
                echo "  selective  - Selective customization (DNS, CLI, Observer custom)"
                ;;
        esac
    done
    echo ""
    echo "BUILD_TARGET options:"
    echo "  smartelligent_x86_64_defconfig  - Generic x86_64 (default)"
    echo "  smartelligent_green_defconfig   - Home Assistant Green"
    echo "  smartelligent_raspberrypi_defconfig - Raspberry Pi"
    echo ""
    echo "Examples:"
    echo "  $0 default smartelligent_x86_64_defconfig"
    echo "  $0 full"
    echo "  $0 selective smartelligent_green_defconfig"
    echo ""
    echo "If no CONFIG is specified, 'default' will be used."
    echo "If no BUILD_TARGET is specified, 'smartelligent_x86_64_defconfig' will be used."
}

# Function to set configuration
set_config() {
    local config="$1"
    local config_file="$HASSIO_PKG_DIR/smartelligent-containers.config"
    
    echo "Setting Smartelligent container configuration to: $config"
    
    case "$config" in
        "default")
            # Use the default configuration (already set in the makefile)
            if [ -f "$config_file" ]; then
                rm "$config_file"
            fi
            echo "Using default configuration (main components custom, supporting standard)"
            ;;
        "full")
            cp "$HASSIO_PKG_DIR/smartelligent-containers-full.config" "$config_file"
            echo "Using full custom configuration (all containers custom)"
            ;;
        "hybrid")
            cp "$HASSIO_PKG_DIR/smartelligent-containers-hybrid.config" "$config_file"
            echo "Using hybrid configuration (main custom, supporting standard)"
            ;;
        "selective")
            cp "$HASSIO_PKG_DIR/smartelligent-containers-selective.config" "$config_file"
            echo "Using selective configuration (DNS, CLI, Observer custom)"
            ;;
        *)
            echo "Error: Unknown configuration '$config'"
            show_usage
            exit 1
            ;;
    esac
}

# Function to validate build target
validate_build_target() {
    local target="$1"
    local config_dir="$SCRIPT_DIR/../buildroot-external/configs"
    
    if [ ! -f "$config_dir/${target}" ]; then
        echo "Error: Build target '$target' not found in $config_dir"
        echo "Available targets:"
        ls -1 "$config_dir"/*.defconfig | sed 's|.*/||' | sed 's|\.defconfig||' | sed 's/^/  /'
        exit 1
    fi
}

# Function to build the OS
build_os() {
    local target="$1"
    
    echo "Building Smartelligent OS with target: $target"
    echo ""
    
    # Enter build environment
    echo "Entering build environment..."
    ./scripts/enter.sh
    
    # Load configuration
    echo "Loading configuration..."
    make "$target"
    
    # Build the system
    echo "Building Smartelligent OS..."
    make
    
    echo ""
    echo "Build completed successfully!"
    echo "OS image available in: output/images/"
}

# Main script logic
main() {
    # Parse arguments
    CONFIG="${1:-default}"
    BUILD_TARGET="${2:-smartelligent_x86_64_defconfig}"
    
    # Show help if requested
    if [ "$CONFIG" = "-h" ] || [ "$CONFIG" = "--help" ]; then
        show_usage
        exit 0
    fi
    
    # Validate configuration
    if [[ ! " ${CONFIGS[*]} " =~ " ${CONFIG} " ]]; then
        echo "Error: Unknown configuration '$CONFIG'"
        show_usage
        exit 1
    fi
    
    # Validate build target
    validate_build_target "$BUILD_TARGET"
    
    # Set configuration
    set_config "$CONFIG"
    
    # Show configuration summary
    echo ""
    echo "Configuration Summary:"
    echo "  Config: $CONFIG"
    echo "  Target: $BUILD_TARGET"
    echo "  Config file: $HASSIO_PKG_DIR/smartelligent-containers.config"
    echo ""
    
    # Ask for confirmation
    read -p "Proceed with build? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 0
    fi
    
    # Build the OS
    build_os "$BUILD_TARGET"
}

# Run main function
main "$@" 
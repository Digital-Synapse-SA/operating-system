#!/usr/bin/env bash

set -e
set -u

# Script to load Smartelligent container configuration
# This script reads the configuration file and exports variables for the build process

CONFIG_FILE="$(dirname "$0")/smartelligent-containers.config"

echo "Loading Smartelligent container configuration..."

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Warning: Configuration file not found: $CONFIG_FILE"
    echo "Using default configuration..."
    
    # Default configuration
    export SMARTELLIGENT_CORE_REPO="https://github.com/Digital-Synapse-SA/core.git"
    export SMARTELLIGENT_FRONTEND_REPO="https://github.com/Digital-Synapse-SA/frontend.git"
    export SMARTELLIGENT_SUPERVISOR_REPO="https://github.com/Digital-Synapse-SA/supervisor.git"
    
    # Default to standard containers for supporting components
    export SMARTELLIGENT_USE_CUSTOM_DNS="n"
    export SMARTELLIGENT_USE_CUSTOM_AUDIO="n"
    export SMARTELLIGENT_USE_CUSTOM_CLI="n"
    export SMARTELLIGENT_USE_CUSTOM_MULTICAST="n"
    export SMARTELLIGENT_USE_CUSTOM_OBSERVER="n"
    
    export SMARTELLIGENT_DNS_REPO=""
    export SMARTELLIGENT_AUDIO_REPO=""
    export SMARTELLIGENT_CLI_REPO=""
    export SMARTELLIGENT_MULTICAST_REPO=""
    export SMARTELLIGENT_OBSERVER_REPO=""
else
    echo "Loading configuration from: $CONFIG_FILE"
    
    # Source the configuration file
    # shellcheck source=smartelligent-containers.config
    source "$CONFIG_FILE"
    
    # Export all variables
    export SMARTELLIGENT_CORE_REPO
    export SMARTELLIGENT_FRONTEND_REPO
    export SMARTELLIGENT_SUPERVISOR_REPO
    export SMARTELLIGENT_USE_CUSTOM_DNS
    export SMARTELLIGENT_USE_CUSTOM_AUDIO
    export SMARTELLIGENT_USE_CUSTOM_CLI
    export SMARTELLIGENT_USE_CUSTOM_MULTICAST
    export SMARTELLIGENT_USE_CUSTOM_OBSERVER
    export SMARTELLIGENT_DNS_REPO
    export SMARTELLIGENT_AUDIO_REPO
    export SMARTELLIGENT_CLI_REPO
    export SMARTELLIGENT_MULTICAST_REPO
    export SMARTELLIGENT_OBSERVER_REPO
fi

# Validate configuration
echo "Configuration loaded:"
echo "  Core: $SMARTELLIGENT_CORE_REPO"
echo "  Frontend: $SMARTELLIGENT_FRONTEND_REPO"
echo "  Supervisor: $SMARTELLIGENT_SUPERVISOR_REPO"
echo "  DNS: $([ "$SMARTELLIGENT_USE_CUSTOM_DNS" = "y" ] && echo "custom ($SMARTELLIGENT_DNS_REPO)" || echo "standard")"
echo "  Audio: $([ "$SMARTELLIGENT_USE_CUSTOM_AUDIO" = "y" ] && echo "custom ($SMARTELLIGENT_AUDIO_REPO)" || echo "standard")"
echo "  CLI: $([ "$SMARTELLIGENT_USE_CUSTOM_CLI" = "y" ] && echo "custom ($SMARTELLIGENT_CLI_REPO)" || echo "standard")"
echo "  Multicast: $([ "$SMARTELLIGENT_USE_CUSTOM_MULTICAST" = "y" ] && echo "custom ($SMARTELLIGENT_MULTICAST_REPO)" || echo "standard")"
echo "  Observer: $([ "$SMARTELLIGENT_USE_CUSTOM_OBSERVER" = "y" ] && echo "custom ($SMARTELLIGENT_OBSERVER_REPO)" || echo "standard")"

# Validate required repositories
if [ "$SMARTELLIGENT_USE_CUSTOM_DNS" = "y" ] && [ -z "$SMARTELLIGENT_DNS_REPO" ]; then
    echo "Error: DNS repository URL is required when using custom DNS"
    exit 1
fi

if [ "$SMARTELLIGENT_USE_CUSTOM_AUDIO" = "y" ] && [ -z "$SMARTELLIGENT_AUDIO_REPO" ]; then
    echo "Error: Audio repository URL is required when using custom audio"
    exit 1
fi

if [ "$SMARTELLIGENT_USE_CUSTOM_CLI" = "y" ] && [ -z "$SMARTELLIGENT_CLI_REPO" ]; then
    echo "Error: CLI repository URL is required when using custom CLI"
    exit 1
fi

if [ "$SMARTELLIGENT_USE_CUSTOM_MULTICAST" = "y" ] && [ -z "$SMARTELLIGENT_MULTICAST_REPO" ]; then
    echo "Error: Multicast repository URL is required when using custom multicast"
    exit 1
fi

if [ "$SMARTELLIGENT_USE_CUSTOM_OBSERVER" = "y" ] && [ -z "$SMARTELLIGENT_OBSERVER_REPO" ]; then
    echo "Error: Observer repository URL is required when using custom observer"
    exit 1
fi

echo "Configuration validation passed!" 
#!/usr/bin/env bash

set -e
set -o pipefail

# Script to build custom Smartelligent containers from Digital-Synapse-SA repositories
# Now supports variable repositories for all containers with fallback options

# Main component repositories
CORE_REPO="${1:-}"
FRONTEND_REPO="${2:-}"
SUPERVISOR_REPO="${3:-}"

# Supporting component repositories
DNS_REPO="${4:-}"
AUDIO_REPO="${5:-}"
CLI_REPO="${6:-}"
MULTICAST_REPO="${7:-}"
OBSERVER_REPO="${8:-}"

# Configuration flags for each container
USE_CUSTOM_DNS="${9:-n}"
USE_CUSTOM_AUDIO="${10:-n}"
USE_CUSTOM_CLI="${11:-n}"
USE_CUSTOM_MULTICAST="${12:-n}"
USE_CUSTOM_OBSERVER="${13:-n}"

# Build directories
IMAGES_DIR="${14:-}"
DL_DIR="${15:-}"

# Validate required parameters
if [ -z "$CORE_REPO" ] || [ -z "$FRONTEND_REPO" ] || [ -z "$SUPERVISOR_REPO" ]; then
    echo "Error: Required repository URLs not provided"
    echo "Usage: $0 <core_repo> <frontend_repo> <supervisor_repo> <dns_repo> <audio_repo> <cli_repo> <multicast_repo> <observer_repo> <use_custom_dns> <use_custom_audio> <use_custom_cli> <use_custom_multicast> <use_custom_observer> <images_dir> <dl_dir>"
    exit 1
fi

if [ -z "$IMAGES_DIR" ] || [ -z "$DL_DIR" ]; then
    echo "Error: Required directories not provided"
    exit 1
fi

BUILD_DIR="/tmp/smartelligent-build"
CACHE_DIR="$DL_DIR/smartelligent-cache"

echo "Building Smartelligent containers from Digital-Synapse-SA repositories..."
echo "Configuration:"
echo "  DNS: $USE_CUSTOM_DNS (repo: $DNS_REPO)"
echo "  Audio: $USE_CUSTOM_AUDIO (repo: $AUDIO_REPO)"
echo "  CLI: $USE_CUSTOM_CLI (repo: $CLI_REPO)"
echo "  Multicast: $USE_CUSTOM_MULTICAST (repo: $MULTICAST_REPO)"
echo "  Observer: $USE_CUSTOM_OBSERVER (repo: $OBSERVER_REPO)"

# Create build directories
mkdir -p "$BUILD_DIR"
mkdir -p "$CACHE_DIR"
mkdir -p "$IMAGES_DIR"

# Function to build container from repository
build_container() {
    local repo_url="$1"
    local container_name="$2"
    local use_custom="$3"
    
    echo "Building $container_name..."
    
    if [ "$use_custom" = "y" ] && [ -n "$repo_url" ]; then
        echo "  Using custom repository: $repo_url"
        
        # Clone or update repository
        if [ ! -d "$BUILD_DIR/$container_name" ]; then
            git clone "$repo_url" "$BUILD_DIR/$container_name"
        else
            cd "$BUILD_DIR/$container_name"
            git pull origin main
            cd - > /dev/null 2>&1 || true
        fi
        
        # Build container
        cd "$BUILD_DIR/$container_name"
        
        # Special handling for frontend (needs build step)
        if [ "$container_name" = "frontend" ]; then
            echo "  Building frontend assets..."
            if command -v yarn > /dev/null; then
                yarn install --frozen-lockfile
                yarn build
            else
                echo "  Warning: yarn not found, skipping frontend build"
            fi
        fi
        
        # Build Docker image
        docker build -t "smartelligent/$container_name:latest" .
        
        # Save to tar file
        local tar_file="$IMAGES_DIR/smartelligent-$container_name.tar"
        docker save "smartelligent/$container_name:latest" > "$tar_file"
        
        echo "  Saved custom $container_name to $tar_file"
        cd - > /dev/null 2>&1 || true
    else
        echo "  Using standard container for $container_name"
        build_standard_container "$container_name"
    fi
}

# Function to build standard container
build_standard_container() {
    local container_name="$1"
    
    echo "  Building standard $container_name container..."
    
    case "$container_name" in
        "dns")
            cat > "$BUILD_DIR/dns/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache dnsmasq
EXPOSE 53/udp
CMD ["dnsmasq", "-k"]
EOF
            ;;
        "audio")
            cat > "$BUILD_DIR/audio/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache pulseaudio
EXPOSE 4713
CMD ["pulseaudio", "--system"]
EOF
            ;;
        "cli")
            cat > "$BUILD_DIR/cli/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache bash curl jq
COPY --from=smartelligent/supervisor:latest /usr/local/bin/ha /usr/local/bin/ha
CMD ["/usr/local/bin/ha"]
EOF
            ;;
        "multicast")
            cat > "$BUILD_DIR/multicast/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache avahi
EXPOSE 5353/udp
CMD ["avahi-daemon"]
EOF
            ;;
        "observer")
            cat > "$BUILD_DIR/observer/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache htop iotop
CMD ["htop"]
EOF
            ;;
        *)
            echo "  Unknown container: $container_name"
            return 1
            ;;
    esac
    
    docker build -t "smartelligent/$container_name:latest" "$BUILD_DIR/$container_name"
    docker save "smartelligent/$container_name:latest" > "$IMAGES_DIR/smartelligent-$container_name.tar"
    echo "  Saved standard $container_name to $IMAGES_DIR/smartelligent-$container_name.tar"
}

# Build main containers (always custom)
echo "Building main Smartelligent containers..."
build_container "$CORE_REPO" "core" "y"
build_container "$FRONTEND_REPO" "frontend" "y"
build_container "$SUPERVISOR_REPO" "supervisor" "y"

# Build supporting containers (configurable)
echo "Building supporting Smartelligent containers..."
build_container "$DNS_REPO" "dns" "$USE_CUSTOM_DNS"
build_container "$AUDIO_REPO" "audio" "$USE_CUSTOM_AUDIO"
build_container "$CLI_REPO" "cli" "$USE_CUSTOM_CLI"
build_container "$MULTICAST_REPO" "multicast" "$USE_CUSTOM_MULTICAST"
build_container "$OBSERVER_REPO" "observer" "$USE_CUSTOM_OBSERVER"

echo "All Smartelligent containers built successfully!"
echo "Container images saved in: $IMAGES_DIR"
echo ""
echo "Summary:"
echo "  Main containers (custom): core, frontend, supervisor"
echo "  Supporting containers:"
echo "    DNS: $([ "$USE_CUSTOM_DNS" = "y" ] && echo "custom" || echo "standard")"
echo "    Audio: $([ "$USE_CUSTOM_AUDIO" = "y" ] && echo "custom" || echo "standard")"
echo "    CLI: $([ "$USE_CUSTOM_CLI" = "y" ] && echo "custom" || echo "standard")"
echo "    Multicast: $([ "$USE_CUSTOM_MULTICAST" = "y" ] && echo "custom" || echo "standard")"
echo "    Observer: $([ "$USE_CUSTOM_OBSERVER" = "y" ] && echo "custom" || echo "standard")" 
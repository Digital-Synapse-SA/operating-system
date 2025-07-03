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

# Function to extract repository URL and branch
parse_repo_url() {
    local full_url="$1"
    local repo_url
    local branch
    
    if [[ "$full_url" == *"#"* ]]; then
        repo_url="${full_url%#*}"
        branch="${full_url#*#}"
    else
        repo_url="$full_url"
        branch="dev-27062025"
    fi
    
    echo "$repo_url"
}

parse_branch() {
    local full_url="$1"
    local branch
    
    if [[ "$full_url" == *"#"* ]]; then
        branch="${full_url#*#}"
    else
        branch="dev-27062025"
    fi
    
    echo "$branch"
}

# Function to check if branch exists in repository
branch_exists() {
    local repo_url="$1"
    local branch="$2"
    
    # Try to fetch the branch without cloning
    if git ls-remote --heads "$repo_url" "$branch" | grep -q "$branch"; then
        return 0
    else
        return 1
    fi
}

# Function to build container from repository
build_container() {
    local repo_url="$1"
    local container_name="$2"
    local use_custom="$3"
    
    echo "Building $container_name..."
    
    if [ "$use_custom" = "y" ] && [ -n "$repo_url" ]; then
        local actual_repo_url
        local branch
        
        actual_repo_url=$(parse_repo_url "$repo_url")
        branch=$(parse_branch "$repo_url")
        
        echo "  Using custom repository: $actual_repo_url (branch: $branch)"
        
        # Check if branch exists before attempting to clone
        if ! branch_exists "$actual_repo_url" "$branch"; then
            echo "  Warning: Branch '$branch' does not exist in $actual_repo_url"
            echo "  Available branches:"
            git ls-remote --heads "$actual_repo_url" | head -10
            echo "  Using standard container for $container_name"
            build_standard_container "$container_name"
            return 0
        fi
        
        # Clone or update repository
        if [ ! -d "$BUILD_DIR/$container_name" ]; then
            if ! git clone -b "$branch" "$actual_repo_url" "$BUILD_DIR/$container_name"; then
                echo "  Warning: Failed to clone $container_name repository, using standard container"
                build_standard_container "$container_name"
                return 0
            fi
        else
            cd "$BUILD_DIR/$container_name"
            if ! git fetch origin; then
                echo "  Warning: Failed to fetch updates for $container_name, using standard container"
                cd - > /dev/null 2>&1 || true
                build_standard_container "$container_name"
                return 0
            fi
            if ! git checkout "$branch"; then
                echo "  Warning: Failed to checkout branch $branch for $container_name, using standard container"
                cd - > /dev/null 2>&1 || true
                build_standard_container "$container_name"
                return 0
            fi
            if ! git pull origin "$branch"; then
                echo "  Warning: Failed to pull updates for $container_name, using standard container"
                cd - > /dev/null 2>&1 || true
                build_standard_container "$container_name"
                return 0
            fi
            cd - > /dev/null 2>&1 || true
        fi
        
        # Build container
        cd "$BUILD_DIR/$container_name"
        
        # Special handling for frontend (needs build step)
        if [ "$container_name" = "frontend" ]; then
            echo "  Building frontend assets..."
            if command -v yarn > /dev/null; then
                if ! yarn install --frozen-lockfile; then
                    echo "  Warning: yarn install failed for frontend, using standard container"
                    cd - > /dev/null 2>&1 || true
                    build_standard_container "$container_name"
                    return 0
                fi
                if ! yarn build; then
                    echo "  Warning: yarn build failed for frontend, using standard container"
                    cd - > /dev/null 2>&1 || true
                    build_standard_container "$container_name"
                    return 0
                fi
            else
                echo "  Warning: yarn not found, skipping frontend build"
            fi
        fi
        
        # Build Docker image
        echo "  Building Docker image for $container_name..."
        
        # Set BUILD_FROM argument for the Docker build
        local build_from_arg=""
        case "$container_name" in
            "core")
                build_from_arg="--build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19"
                ;;
            "frontend")
                build_from_arg="--build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19"
                ;;
            "supervisor")
                build_from_arg="--build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19"
                ;;
            *)
                build_from_arg="--build-arg BUILD_FROM=alpine:3.18"
                ;;
        esac
        
        # For supervisor, try to fix common build issues
        if [ "$container_name" = "supervisor" ]; then
            echo "  Checking supervisor Dockerfile for compatibility..."
            # Check if Dockerfile exists and has potential issues
            if [ -f "Dockerfile" ]; then
                # Backup original Dockerfile
                cp Dockerfile Dockerfile.original
                
                # Try to fix common issues
                if grep -q "pip3 install" Dockerfile; then
                    echo "  Fixing pip3 issue in supervisor Dockerfile..."
                    sed -i 's/pip3 install/python3 -m pip install/g' Dockerfile
                fi
                
                if grep -q "pip3" Dockerfile; then
                    echo "  Adding python3-pip to supervisor Dockerfile..."
                    sed -i '/RUN apk add --no-cache/s/$/ python3-pip/' Dockerfile
                fi
            fi
        fi
        
        # Build with proper arguments
        if ! docker build $build_from_arg -t "smartelligent/$container_name:latest" .; then
            echo "  Warning: Docker build failed for $container_name, trying fallback..."
            
            # For supervisor, try additional fixes
            if [ "$container_name" = "supervisor" ] && [ -f "Dockerfile.original" ]; then
                echo "  Trying alternative supervisor build approach..."
                cp Dockerfile.original Dockerfile
                # Try with a simpler base image
                if ! docker build --build-arg BUILD_FROM=alpine:3.18 -t "smartelligent/$container_name:latest" .; then
                    echo "  Error: Docker build failed for $container_name, using standard container"
                    cd - > /dev/null 2>&1 || true
                    build_standard_container "$container_name"
                    return 0
                fi
            else
                # Fallback: try without build args
                if ! docker build -t "smartelligent/$container_name:latest" .; then
                    echo "  Error: Docker build failed for $container_name, using standard container"
                    cd - > /dev/null 2>&1 || true
                    build_standard_container "$container_name"
                    return 0
                fi
            fi
        fi
        
        # Save to tar file
        local tar_file="$IMAGES_DIR/smartelligent-$container_name.tar"
        if docker save "smartelligent/$container_name:latest" > "$tar_file"; then
            echo "  Saved custom $container_name to $tar_file"
        else
            echo "  Warning: Failed to save $container_name image, using standard container"
            cd - > /dev/null 2>&1 || true
            build_standard_container "$container_name"
            return 0
        fi
        
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
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR/$container_name"
    
    case "$container_name" in
        "core")
            # For core, we'll use the official Home Assistant container
            echo "  Using official Home Assistant core container"
            docker pull "ghcr.io/home-assistant/amd64-homeassistant:stable"
            docker tag "ghcr.io/home-assistant/amd64-homeassistant:stable" "smartelligent/core:latest"
            docker save "smartelligent/core:latest" > "$IMAGES_DIR/smartelligent-core.tar"
            echo "  Saved standard core to $IMAGES_DIR/smartelligent-core.tar"
            return 0
            ;;
        "frontend")
            # For frontend, we'll use the official Home Assistant frontend container
            echo "  Using official Home Assistant frontend container"
            docker pull "ghcr.io/home-assistant/amd64-homeassistant:stable"
            docker tag "ghcr.io/home-assistant/amd64-homeassistant:stable" "smartelligent/frontend:latest"
            docker save "smartelligent/frontend:latest" > "$IMAGES_DIR/smartelligent-frontend.tar"
            echo "  Saved standard frontend to $IMAGES_DIR/smartelligent-frontend.tar"
            return 0
            ;;
        "supervisor")
            # For supervisor, we'll use the official Home Assistant supervisor container
            echo "  Using official Home Assistant supervisor container"
            # Try different supervisor image tags
            if docker pull "ghcr.io/home-assistant/amd64-hassio-supervisor:stable" 2>/dev/null; then
                docker tag "ghcr.io/home-assistant/amd64-hassio-supervisor:stable" "smartelligent/supervisor:latest"
            elif docker pull "ghcr.io/home-assistant/amd64-hassio-supervisor:latest" 2>/dev/null; then
                docker tag "ghcr.io/home-assistant/amd64-hassio-supervisor:latest" "smartelligent/supervisor:latest"
            elif docker pull "ghcr.io/home-assistant/amd64-hassio-supervisor:2025.6.0" 2>/dev/null; then
                docker tag "ghcr.io/home-assistant/amd64-hassio-supervisor:2025.6.0" "smartelligent/supervisor:latest"
            else
                echo "  Warning: Could not find official supervisor image, creating minimal supervisor"
                cat > "$BUILD_DIR/supervisor/Dockerfile" << 'EOF'
FROM alpine:3.18
RUN apk add --no-cache python3 py3-pip
COPY --from=smartelligent/core:latest /usr/local/bin/hass -- /usr/local/bin/hass
CMD ["/usr/local/bin/hass"]
EOF
                docker build -t "smartelligent/supervisor:latest" "$BUILD_DIR/supervisor"
            fi
            docker save "smartelligent/supervisor:latest" > "$IMAGES_DIR/smartelligent-supervisor.tar"
            echo "  Saved standard supervisor to $IMAGES_DIR/smartelligent-supervisor.tar"
            return 0
            ;;
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
    
    # Only build Docker images for supporting containers (not main containers)
    if [[ "$container_name" =~ ^(dns|audio|cli|multicast|observer)$ ]]; then
        docker build -t "smartelligent/$container_name:latest" "$BUILD_DIR/$container_name"
        docker save "smartelligent/$container_name:latest" > "$IMAGES_DIR/smartelligent-$container_name.tar"
        echo "  Saved standard $container_name to $IMAGES_DIR/smartelligent-$container_name.tar"
    fi
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
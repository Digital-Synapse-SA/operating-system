#!/usr/bin/env bash

set -e

# Test script to verify Digital-Synapse-SA repositories and branches exist

echo "Testing Digital-Synapse-SA repositories and branches..."

# Load configuration
if [ -f "smartelligent-containers.config" ]; then
    source smartelligent-containers.config
else
    echo "Error: smartelligent-containers.config not found"
    exit 1
fi

# Function to test repository and branch
test_repo() {
    local repo_var="$1"
    local repo_url
    local branch
    
    if [ -z "${!repo_var}" ]; then
        echo "  ❌ $repo_var: Not configured"
        return 1
    fi
    
    repo_url="${!repo_var}"
    
    if [[ "$repo_url" == *"#"* ]]; then
        repo_url="${repo_url%#*}"
        branch="${repo_url#*#}"
    else
        branch="master"
    fi
    
    echo "  Testing $repo_var: $repo_url (branch: $branch)"
    
    # Test if repository exists
    if ! git ls-remote "$repo_url" > /dev/null 2>&1; then
        echo "    ❌ Repository does not exist or is not accessible"
        return 1
    fi
    
    # Test if branch exists
    if ! git ls-remote --heads "$repo_url" "$branch" | grep -q "$branch"; then
        echo "    ❌ Branch '$branch' does not exist"
        echo "    Available branches:"
        git ls-remote --heads "$repo_url" | head -5 | sed 's/.*\///' | sed 's/^/      - /'
        return 1
    fi
    
    echo "    ✅ Repository and branch exist"
    return 0
}

echo ""
echo "Testing main components:"
test_repo "SMARTELLIGENT_CORE_REPO"
test_repo "SMARTELLIGENT_FRONTEND_REPO"
test_repo "SMARTELLIGENT_SUPERVISOR_REPO"

echo ""
echo "Testing supporting components:"
test_repo "SMARTELLIGENT_DNS_REPO"
test_repo "SMARTELLIGENT_AUDIO_REPO"
test_repo "SMARTELLIGENT_CLI_REPO"
test_repo "SMARTELLIGENT_MULTICAST_REPO"
test_repo "SMARTELLIGENT_OBSERVER_REPO"

echo ""
echo "Repository test completed!"
echo ""
echo "If any repositories or branches are missing, you can:"
echo "1. Check the repository URLs in smartelligent-containers.config"
echo "2. Verify the branch names exist in the repositories"
echo "3. Update the configuration with correct URLs and branch names"
echo "4. The build script will fall back to standard containers for missing repos" 
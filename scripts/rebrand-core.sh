#!/usr/bin/env bash

set -e
set -u

# Smartelligent Core Rebranding Script
# This script rebrands the Home Assistant core to Smartelligent

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$SCRIPT_DIR/../core"

echo "Starting Smartelligent core rebranding..."
echo "Core directory: $CORE_DIR"

# Check if core directory exists
if [ ! -d "$CORE_DIR" ]; then
    echo "Error: Core directory not found at $CORE_DIR"
    echo "Please run this script from the operating-system directory"
    exit 1
fi

# Create backup
BACKUP_DIR="$CORE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup at: $BACKUP_DIR"
cp -r "$CORE_DIR/homeassistant" "$BACKUP_DIR"

echo "Backup created successfully"

# Function to safely replace text in files
safe_replace() {
    local pattern="$1"
    local replacement="$2"
    local file_pattern="$3"
    
    echo "Replacing '$pattern' with '$replacement' in $file_pattern files..."
    
    find "$CORE_DIR/homeassistant" -name "$file_pattern" -type f -exec sed -i.bak "s/$pattern/$replacement/g" {} \;
    
    # Remove backup files created by sed
    find "$CORE_DIR/homeassistant" -name "*.bak" -delete
}

# Phase 1: Update Python files
echo ""
echo "Phase 1: Updating Python files..."

# Update APPLICATION_NAME constant
echo "Updating APPLICATION_NAME constant..."
sed -i.bak 's/APPLICATION_NAME: Final = "HomeAssistant"/APPLICATION_NAME: Final = "Smartelligent"/' "$CORE_DIR/homeassistant/const.py"
rm "$CORE_DIR/homeassistant/const.py.bak"

# Update docstrings and comments
safe_replace "Home Assistant" "Smartelligent" "*.py"
safe_replace "homeassistant" "smartelligent" "*.py"

# Phase 2: Update JSON files
echo ""
echo "Phase 2: Updating JSON files..."
safe_replace "Home Assistant" "Smartelligent" "*.json"

# Phase 3: Update documentation files
echo ""
echo "Phase 3: Updating documentation files..."
safe_replace "Home Assistant" "Smartelligent" "*.md"
safe_replace "homeassistant" "smartelligent" "*.md"

# Phase 4: Update specific strings in strings.json
echo ""
echo "Phase 4: Updating specific strings in strings.json..."

# Update specific entries that need careful handling
sed -i.bak 's/"Not connected to Home Assistant Cloud."/"Not connected to Smartelligent Cloud."/g' "$CORE_DIR/homeassistant/strings.json"
sed -i.bak 's/"Control Home Assistant"/"Control Smartelligent"/g' "$CORE_DIR/homeassistant/strings.json"
sed -i.bak 's/"via Home Assistant add-on"/"via Smartelligent add-on"/g' "$CORE_DIR/homeassistant/strings.json"
sed -i.bak 's/"Your Home Assistant instance"/"Your Smartelligent instance"/g' "$CORE_DIR/homeassistant/strings.json"

rm "$CORE_DIR/homeassistant/strings.json.bak"

# Phase 5: Update setup.py docstring
echo ""
echo "Phase 5: Updating setup.py docstring..."
sed -i.bak 's/All methods needed to bootstrap a Home Assistant instance./All methods needed to bootstrap a Smartelligent instance./g' "$CORE_DIR/homeassistant/setup.py"
rm "$CORE_DIR/homeassistant/setup.py.bak"

# Phase 6: Update any remaining references
echo ""
echo "Phase 6: Final cleanup..."

# Update any remaining "HomeAssistant" (no space) references
safe_replace "HomeAssistant" "Smartelligent" "*.py"
safe_replace "HomeAssistant" "Smartelligent" "*.json"

# Update any remaining "HASS" references to "SMART"
safe_replace "HASS" "SMART" "*.py"

echo ""
echo "Core rebranding completed successfully!"
echo ""
echo "Summary of changes:"
echo "  ✅ APPLICATION_NAME updated to 'Smartelligent'"
echo "  ✅ Python files updated"
echo "  ✅ JSON files updated"
echo "  ✅ Documentation files updated"
echo "  ✅ String resources updated"
echo "  ✅ Setup documentation updated"
echo ""
echo "Backup created at: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Test the core functionality"
echo "  2. Run validation script: ./scripts/validate-rebranding.sh"
echo "  3. Build and test the complete system"
echo ""
echo "If issues arise, you can restore from backup:"
echo "  cp -r $BACKUP_DIR $CORE_DIR/homeassistant" 
#!/usr/bin/env bash

set -e
set -u

# Smartelligent Rebranding Validation Script
# This script validates that the rebranding was successful

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$SCRIPT_DIR/../core"
FRONTEND_DIR="$SCRIPT_DIR/../frontend"
SUPERVISOR_DIR="$SCRIPT_DIR/../supervisor"

echo "Validating Smartelligent rebranding..."
echo "======================================"

# Function to check for references
check_references() {
    local directory="$1"
    local pattern="$2"
    local description="$3"
    
    echo ""
    echo "Checking for '$pattern' in $description..."
    echo "Directory: $directory"
    
    if [ ! -d "$directory" ]; then
        echo "  ⚠️  Directory not found: $directory"
        return
    fi
    
    # Search for the pattern
    local results
    results=$(grep -r "$pattern" "$directory" 2>/dev/null || true)
    
    if [ -n "$results" ]; then
        echo "  ❌ Found $pattern references:"
        echo "$results" | head -20 | sed 's/^/    /'
        if [ "$(echo "$results" | wc -l)" -gt 20 ]; then
            echo "    ... and $(($(echo "$results" | wc -l) - 20)) more"
        fi
        return 1
    else
        echo "  ✅ No $pattern references found"
        return 0
    fi
}

# Function to check for specific constants
check_constants() {
    local file="$1"
    local pattern="$2"
    local expected="$3"
    local description="$4"
    
    echo ""
    echo "Checking $description..."
    echo "File: $file"
    
    if [ ! -f "$file" ]; then
        echo "  ⚠️  File not found: $file"
        return 1
    fi
    
    local result
    result=$(grep "$pattern" "$file" || true)
    
    if [ -n "$result" ]; then
        echo "  📋 Current value: $result"
        if echo "$result" | grep -q "$expected"; then
            echo "  ✅ Correctly updated to $expected"
            return 0
        else
            echo "  ❌ Still contains old value"
            return 1
        fi
    else
        echo "  ⚠️  Pattern not found: $pattern"
        return 1
    fi
}

# Initialize counters
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Check Core Directory
echo ""
echo "=== CORE DIRECTORY VALIDATION ==="

# Check for remaining "Home Assistant" references
if check_references "$CORE_DIR/homeassistant" "Home Assistant" "core Python files"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check for remaining "homeassistant" references (lowercase)
if check_references "$CORE_DIR/homeassistant" "homeassistant" "core Python files (lowercase)"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check for remaining "HomeAssistant" references (no space)
if check_references "$CORE_DIR/homeassistant" "HomeAssistant" "core Python files (no space)"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check APPLICATION_NAME constant
if check_constants "$CORE_DIR/homeassistant/const.py" "APPLICATION_NAME.*=" "Smartelligent" "APPLICATION_NAME constant"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check strings.json for specific entries
echo ""
echo "Checking strings.json for specific entries..."
if [ -f "$CORE_DIR/homeassistant/strings.json" ]; then
    echo "File: $CORE_DIR/homeassistant/strings.json"
    
    # Check for "Smartelligent Cloud" reference
    if grep -q "Smartelligent Cloud" "$CORE_DIR/homeassistant/strings.json"; then
        echo "  ✅ 'Smartelligent Cloud' reference found"
        ((PASSED_CHECKS++))
    else
        echo "  ❌ 'Smartelligent Cloud' reference not found"
    fi
    ((TOTAL_CHECKS++))
    
    # Check for "Control Smartelligent" reference
    if grep -q "Control Smartelligent" "$CORE_DIR/homeassistant/strings.json"; then
        echo "  ✅ 'Control Smartelligent' reference found"
        ((PASSED_CHECKS++))
    else
        echo "  ❌ 'Control Smartelligent' reference not found"
    fi
    ((TOTAL_CHECKS++))
    
    # Check for "via Smartelligent add-on" reference
    if grep -q "via Smartelligent add-on" "$CORE_DIR/homeassistant/strings.json"; then
        echo "  ✅ 'via Smartelligent add-on' reference found"
        ((PASSED_CHECKS++))
    else
        echo "  ❌ 'via Smartelligent add-on' reference not found"
    fi
    ((TOTAL_CHECKS++))
else
    echo "  ⚠️  strings.json not found"
    ((TOTAL_CHECKS+=3))
fi

# Check Frontend Directory
echo ""
echo "=== FRONTEND DIRECTORY VALIDATION ==="

# Check for remaining "Home Assistant" references
if check_references "$FRONTEND_DIR/src" "Home Assistant" "frontend source files"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check for "Smartelligent" references
if check_references "$FRONTEND_DIR/src" "Smartelligent" "frontend Smartelligent references"; then
    echo "  ✅ Smartelligent branding found in frontend"
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check Supervisor Directory
echo ""
echo "=== SUPERVISOR DIRECTORY VALIDATION ==="

# Check for remaining "Home Assistant" references
if check_references "$SUPERVISOR_DIR/supervisor" "Home Assistant" "supervisor Python files"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check for "Smartelligent" references
if check_references "$SUPERVISOR_DIR/supervisor" "Smartelligent" "supervisor Smartelligent references"; then
    echo "  ✅ Smartelligent branding found in supervisor"
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check Operating System Directory
echo ""
echo "=== OPERATING SYSTEM DIRECTORY VALIDATION ==="

# Check for "Smartelligent" references in OS configs
if check_references "$SCRIPT_DIR/../buildroot-external" "Smartelligent" "OS configuration files"; then
    echo "  ✅ Smartelligent branding found in OS configs"
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Check for remaining "Home Assistant" references in OS configs
if check_references "$SCRIPT_DIR/../buildroot-external" "Home Assistant" "OS configuration files"; then
    ((PASSED_CHECKS++))
fi
((TOTAL_CHECKS++))

# Summary
echo ""
echo "======================================"
echo "VALIDATION SUMMARY"
echo "======================================"
echo "Total checks: $TOTAL_CHECKS"
echo "Passed checks: $PASSED_CHECKS"
echo "Failed checks: $((TOTAL_CHECKS - PASSED_CHECKS))"
echo "Success rate: $((PASSED_CHECKS * 100 / TOTAL_CHECKS))%"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo ""
    echo "🎉 All validation checks passed!"
    echo "The Smartelligent rebranding appears to be complete and successful."
else
    echo ""
    echo "⚠️  Some validation checks failed."
    echo "Please review the failed checks above and fix any remaining issues."
    echo ""
    echo "Common issues to check:"
    echo "  1. Run the rebranding script again: ./scripts/rebrand-core.sh"
    echo "  2. Check for case-sensitive references"
    echo "  3. Look for references in comments or docstrings"
    echo "  4. Verify all directories exist"
fi

echo ""
echo "Next steps:"
echo "  1. Test the complete system functionality"
echo "  2. Build and deploy the Smartelligent OS"
echo "  3. Verify all integrations work correctly" 
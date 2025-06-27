# Core Rebranding Plan for Smartelligent

## Overview

The Home Assistant core application needs to be rebranded to "Smartelligent" to complete the rebranding process. This document outlines all the changes needed.

## Key Files to Modify

### 1. `core/homeassistant/const.py`
**Line 25:** `APPLICATION_NAME: Final = "HomeAssistant"`
**Change to:** `APPLICATION_NAME: Final = "Smartelligent"`

### 2. `core/homeassistant/strings.json`
**Multiple entries** containing "Home Assistant" references need to be updated:
- `"cloud_not_connected": "Not connected to Home Assistant Cloud."`
- `"llm_hass_api": "Control Home Assistant"`
- `"via_hassio_addon": "{name} via Home Assistant add-on"`

### 3. `core/homeassistant/setup.py`
**Line 1:** `"""All methods needed to bootstrap a Home Assistant instance."""`
**Change to:** `"""All methods needed to bootstrap a Smartelligent instance."""`

### 4. Additional Files to Check
- `core/homeassistant/core.py` - Main application logic
- `core/homeassistant/config.py` - Configuration handling
- `core/homeassistant/auth/` - Authentication system
- `core/homeassistant/api/` - API endpoints

## Detailed Changes Required

### 1. Application Constants (`const.py`)

```python
# BEFORE
APPLICATION_NAME: Final = "HomeAssistant"

# AFTER  
APPLICATION_NAME: Final = "Smartelligent"
```

### 2. String Resources (`strings.json`)

```json
{
  "common": {
    "config_flow": {
      "abort": {
        "cloud_not_connected": "Not connected to Smartelligent Cloud.",
        "webhook_not_internet_accessible": "Your Smartelligent instance needs to be accessible from the internet to receive webhook messages."
      },
      "data": {
        "llm_hass_api": "Control Smartelligent"
      },
      "title": {
        "via_hassio_addon": "{name} via Smartelligent add-on"
      }
    }
  }
}
```

### 3. Documentation Strings

All docstrings and comments containing "Home Assistant" should be updated to "Smartelligent".

### 4. API Responses

Any API endpoints that return branding information need to be updated.

### 5. Log Messages

All log messages containing "Home Assistant" should be updated to "Smartelligent".

## Implementation Strategy

### Phase 1: Core Constants
1. Update `APPLICATION_NAME` in `const.py`
2. Update version information if needed
3. Test basic functionality

### Phase 2: String Resources
1. Update `strings.json` with Smartelligent branding
2. Update any hardcoded strings in Python files
3. Test UI and error messages

### Phase 3: Documentation and Comments
1. Update all docstrings
2. Update inline comments
3. Update README and documentation files

### Phase 4: API and Integration
1. Update API response formats
2. Update integration names and descriptions
3. Test all integrations

### Phase 5: Testing and Validation
1. Comprehensive testing of all functionality
2. Verify no "Home Assistant" references remain
3. Test with various integrations and add-ons

## Files to Create

### 1. Core Rebranding Script
Create a script to automate the rebranding process:

```bash
#!/bin/bash
# scripts/rebrand-core.sh

# Replace "Home Assistant" with "Smartelligent" in core files
find core/homeassistant -name "*.py" -exec sed -i 's/Home Assistant/Smartelligent/g' {} \;
find core/homeassistant -name "*.json" -exec sed -i 's/Home Assistant/Smartelligent/g' {} \;
find core/homeassistant -name "*.md" -exec sed -i 's/Home Assistant/Smartelligent/g' {} \;

# Update specific constants
sed -i 's/APPLICATION_NAME: Final = "HomeAssistant"/APPLICATION_NAME: Final = "Smartelligent"/' core/homeassistant/const.py
```

### 2. Validation Script
Create a script to verify rebranding:

```bash
#!/bin/bash
# scripts/validate-rebranding.sh

# Check for remaining "Home Assistant" references
echo "Checking for remaining 'Home Assistant' references..."
grep -r "Home Assistant" core/homeassistant/ || echo "No 'Home Assistant' references found!"

echo "Checking for remaining 'homeassistant' references..."
grep -r "homeassistant" core/homeassistant/ || echo "No 'homeassistant' references found!"
```

## Testing Checklist

### Basic Functionality
- [ ] Application starts correctly
- [ ] Configuration loads properly
- [ ] API endpoints work
- [ ] Authentication works
- [ ] Logging works

### UI Integration
- [ ] Frontend displays correct branding
- [ ] Error messages show Smartelligent
- [ ] Configuration flows work
- [ ] Add-on integration works

### Integration Testing
- [ ] All integrations load correctly
- [ ] Device discovery works
- [ ] Automation works
- [ ] Scripts work
- [ ] Scenes work

## Rollback Plan

If issues arise, we can:
1. Revert the core changes
2. Keep frontend and OS rebranding
3. Use a hybrid approach where core remains "Home Assistant" but UI shows "Smartelligent"

## Next Steps

1. **Create the rebranding scripts**
2. **Test on a development branch**
3. **Validate all functionality**
4. **Update documentation**
5. **Deploy to production**

## Important Considerations

### Compatibility
- Some integrations may expect "Home Assistant" in specific places
- API consumers may rely on "Home Assistant" branding
- Third-party tools may break

### Gradual Migration
- Consider keeping some internal references as "Home Assistant"
- Use "Smartelligent" for user-facing content
- Maintain API compatibility where possible

### Testing Strategy
- Test with popular integrations
- Test with various device types
- Test automation and scripting
- Test mobile apps and external tools 
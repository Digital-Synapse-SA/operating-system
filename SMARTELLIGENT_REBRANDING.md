# Smartelligent Rebranding Documentation

## Overview

This document describes the rebranding changes made to transform Home Assistant into "Smartelligent" for Digital-Synapse-SA.

## What is Smartelligent?

Smartelligent is a rebranded version of Home Assistant Operating System, customized for deployment on generic Intel CPU minipcs. It maintains all the functionality of Home Assistant while presenting a custom brand identity.

## Key Changes Made

### 1. Operating System Configuration
- **File**: `buildroot-external/configs/smartelligent_x86_64_defconfig`
- **Changes**: 
  - Hostname changed from "homeassistant" to "smartelligent"
  - System issue message changed to "Welcome to Smartelligent"
  - Machine identifier changed to "smartelligent-x86-64"
  - Board identifier changed to "SmartelligentAmd64"

### 2. System Messages
- **File**: `buildroot-external/rootfs-overlay/etc/motd`
- **Changes**: Updated welcome message to display "Smartelligent" instead of "Home Assistant OS"

### 3. Core Update Entities
- **File**: `core/homeassistant/components/hassio/update.py`
- **Changes**: Updated entity titles:
  - "Home Assistant Operating System" → "Smartelligent Operating System"
  - "Home Assistant Supervisor" → "Smartelligent Supervisor"
  - "Home Assistant Core" → "Smartelligent Core"

### 4. Frontend Branding
- **File**: `frontend/src/data/update.ts`
- **Changes**: Updated update entity titles to match core changes

- **File**: `frontend/src/components/ha-sidebar.ts`
- **Changes**: Sidebar title changed from "Home Assistant" to "Smartelligent"

- **File**: `frontend/src/state/panel-title-mixin.ts`
- **Changes**: Browser tab title changed from "Home Assistant" to "Smartelligent"

- **File**: `frontend/src/data/hardware.ts`
- **Changes**: Hardware names updated:
  - "Home Assistant Blue / ODROID-N2" → "Smartelligent Blue / ODROID-N2"
  - "Home Assistant Yellow" → "Smartelligent Yellow"

- **File**: `frontend/src/data/onboarding.ts`
- **Changes**: Installation type names updated to include "Smartelligent Operating System" and "Smartelligent Core"

### 5. Hassio Frontend
- **File**: `frontend/hassio/src/update-available/update-available-card.ts`
- **Changes**: Update names changed to Smartelligent branding

- **File**: `frontend/hassio/src/system/hassio-core-info.ts`
- **Changes**: Restart confirmation dialogs updated to use "Smartelligent Core"

- **File**: `frontend/hassio/src/components/supervisor-backup-content.ts`
- **Changes**: Backup labels changed from "Home Assistant" to "Smartelligent"

### 6. Backup Components
- **File**: `frontend/src/panels/config/backup/components/ha-backup-data-picker.ts`
- **Changes**: Backup data picker labels updated to "Smartelligent"

- **File**: `frontend/src/panels/config/backup/ha-config-backup-settings.ts`
- **Changes**: Cloud backup references updated to "Smartelligent Cloud"

## Build Process

### Prerequisites
- Docker installed and running
- Git repositories for operating-system, supervisor, core, and frontend
- Branch: `dev-27062025`

### Building the Image

1. **Quick Build** (recommended):
   ```bash
   ./build-smartelligent.sh
   ```

2. **Manual Build**:
   ```bash
   ./scripts/enter.sh make smartelligent_x86_64
   ```

### Build Output
The build process will create:
- Smartelligent OS image for generic x86_64 architecture
- Output files in the `output/` directory
- Files with "smartelligent" in the name

## Target Deployment

Smartelligent is designed for deployment on:
- **Architecture**: Generic Intel x86_64
- **Platform**: Mini PCs and similar devices
- **Organization**: Digital-Synapse-SA

## Customization Notes

### What's Changed
- System branding and naming
- UI titles and labels
- Update entity names
- Hardware identification
- Backup and restore labels

### What's Preserved
- All Home Assistant functionality
- Core system architecture
- Add-on compatibility
- API endpoints
- Configuration structure

## Future Considerations

1. **Logo and Icons**: Consider replacing Home Assistant logos with Smartelligent branding
2. **Color Scheme**: Customize the UI color scheme to match Smartelligent branding
3. **Documentation**: Update help text and documentation references
4. **Domain Names**: Update any hardcoded domain references
5. **Legal**: Ensure compliance with Home Assistant licensing terms

## Repository Structure

```
operating-system/
├── buildroot-external/
│   ├── configs/smartelligent_x86_64_defconfig  # New config
│   └── rootfs-overlay/etc/motd                 # Updated welcome message
├── build-smartelligent.sh                      # Build script
└── SMARTELLIGENT_REBRANDING.md                # This documentation

../core/
└── homeassistant/components/hassio/update.py   # Updated entity titles

../frontend/
├── src/
│   ├── data/update.ts                          # Updated update titles
│   ├── data/hardware.ts                        # Updated hardware names
│   ├── data/onboarding.ts                      # Updated installation types
│   ├── components/ha-sidebar.ts                # Updated sidebar title
│   └── state/panel-title-mixin.ts              # Updated page titles
└── hassio/src/
    ├── update-available/update-available-card.ts
    ├── system/hassio-core-info.ts
    └── components/supervisor-backup-content.ts
```

## Support

For questions about the Smartelligent rebranding:
- Organization: Digital-Synapse-SA
- Branch: dev-27062025
- Build Target: smartelligent_x86_64 
# Smartelligent Container Strategy

This document explains how Smartelligent handles the different container components and how to customize them.

## Container Architecture Overview

Smartelligent uses a **hybrid approach** for container management:

### **Main Components (Custom from Digital-Synapse-SA)**
- **Core**: `smartelligent/core:latest` - Main Home Assistant application
- **Frontend**: `smartelligent/frontend:latest` - Web interface
- **Supervisor**: `smartelligent/supervisor:latest` - System management

### **Supporting Components (Standard from Home Assistant)**
- **DNS**: `ghcr.io/home-assistant/amd64-hassio-dns:latest` - Local DNS resolution
- **Audio**: `ghcr.io/home-assistant/amd64-hassio-audio:latest` - Audio management
- **CLI**: `ghcr.io/home-assistant/amd64-hassio-cli:latest` - Command line interface
- **Multicast**: `ghcr.io/home-assistant/amd64-hassio-multicast:latest` - mDNS discovery
- **Observer**: `ghcr.io/home-assistant/amd64-hassio-observer:latest` - System monitoring

## Why This Hybrid Approach?

### **Benefits:**
1. **Focused Customization**: Only customize what needs branding changes
2. **Stability**: Supporting containers are well-tested and maintained
3. **Maintainability**: Easier to update and maintain
4. **Compatibility**: Ensures full Home Assistant ecosystem compatibility

### **Supporting Container Functions:**

#### **DNS (dnsmasq)**
```bash
# Purpose: Local DNS resolution
# Function: Resolves hostnames like smartelligent.local
# Why Standard: System utility, no branding needed
```

#### **Audio (PulseAudio)**
```bash
# Purpose: Audio management for voice assistants
# Function: Handles audio devices and streams
# Why Standard: System utility, no branding needed
```

#### **CLI (Command Line Interface)**
```bash
# Purpose: System administration via command line
# Function: Provides 'ha' command for system management
# Why Standard: Utility tool, branding handled by Supervisor
```

#### **Multicast (Avahi)**
```bash
# Purpose: Device discovery on local network
# Function: mDNS service discovery
# Why Standard: System utility, no branding needed
```

#### **Observer (Monitoring)**
```bash
# Purpose: System monitoring and debugging
# Function: Provides htop, iotop for system monitoring
# Why Standard: System utility, no branding needed
```

## Build Process Flow

### **Step 1: Build Custom Main Containers**
```bash
# Build from Digital-Synapse-SA repositories
build-smartelligent-main.sh
├── smartelligent/core:latest
├── smartelligent/frontend:latest
└── smartelligent/supervisor:latest
```

### **Step 2: Fetch Standard Supporting Containers**
```bash
# Fetch from official Home Assistant registry
fetch-container-image.sh
├── ghcr.io/home-assistant/amd64-hassio-dns:latest
├── ghcr.io/home-assistant/amd64-hassio-audio:latest
├── ghcr.io/home-assistant/amd64-hassio-cli:latest
├── ghcr.io/home-assistant/amd64-hassio-multicast:latest
└── ghcr.io/home-assistant/amd64-hassio-observer:latest
```

### **Step 3: Create Hybrid Version Configuration**
```json
{
  "supervisor": "smartelligent/supervisor:latest",
  "core": "smartelligent/core:latest",
  "dns": "ghcr.io/home-assistant/amd64-hassio-dns:latest",
  "audio": "ghcr.io/home-assistant/amd64-hassio-audio:latest",
  "cli": "ghcr.io/home-assistant/amd64-hassio-cli:latest",
  "multicast": "ghcr.io/home-assistant/amd64-hassio-multicast:latest",
  "observer": "ghcr.io/home-assistant/amd64-hassio-observer:latest"
}
```

## Customization Options

### **Option 1: Keep Hybrid Approach (Recommended)**
- ✅ Use custom Core/Frontend/Supervisor
- ✅ Use standard supporting containers
- ✅ Best balance of customization and stability

### **Option 2: Full Customization**
If you want to customize everything:

```bash
# Create custom supporting containers
build-smartelligent-supporting.sh
├── smartelligent/dns:latest
├── smartelligent/audio:latest
├── smartelligent/cli:latest
├── smartelligent/multicast:latest
└── smartelligent/observer:latest
```

### **Option 3: Minimal Customization**
If you only want basic branding:

```bash
# Only customize Supervisor (handles branding)
# Use standard Core and Frontend
# Use standard supporting containers
```

## Implementation Files

### **Build Scripts:**
- `build-smartelligent-main.sh` - Builds main custom containers
- `build-smartelligent-supporting.sh` - Builds supporting containers (optional)
- `build-smartelligent-containers.sh` - Builds all containers (full custom)

### **Configuration Files:**
- `hassio.mk` - Modified to use hybrid approach
- `smartelligent_x86_64_defconfig` - OS configuration
- `version.json` - Container version mapping

## Deployment Process

### **1. Build Custom Containers**
```bash
./scripts/build-custom-containers.sh
```

### **2. Build OS Image**
```bash
./scripts/enter.sh
make smartelligent_x86_64
```

### **3. Deploy to Mini PC**
```bash
# Flash image to USB
# Boot from USB on mini PC
# System will use hybrid container setup
```

## Troubleshooting

### **Container Build Issues:**
```bash
# Check repository access
git clone https://github.com/Digital-Synapse-SA/core.git

# Check Docker build
docker build -t test/core .

# Check container functionality
docker run --rm test/core --help
```

### **OS Build Issues:**
```bash
# Clean build
make clean
make smartelligent_x86_64

# Check container availability
ls -la output/images/
```

### **Runtime Issues:**
```bash
# Check container status
ha supervisor info

# Check container logs
ha supervisor logs core
ha supervisor logs supervisor
```

## Future Considerations

### **Updates:**
- Custom containers need manual updates
- Supporting containers auto-update from Home Assistant
- Consider automated build pipeline

### **Security:**
- Custom containers inherit your security practices
- Supporting containers follow Home Assistant security standards
- Regular security updates recommended

### **Maintenance:**
- Monitor for Home Assistant updates
- Update custom containers when needed
- Test compatibility with new supporting containers

---

**Note**: This hybrid approach provides the best balance of customization and maintainability for Smartelligent. The supporting containers are system utilities that don't require branding changes, while the main components carry your Smartelligent branding. 
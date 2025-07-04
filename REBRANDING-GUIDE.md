# Smartelligent Home - Rebranded Home Assistant

This guide explains how to build a rebranded version of Home Assistant called "Smartelligent Home". The solution maintains the existing Home Assistant build system while allowing you to customize the frontend branding and pull your own container images.

## 🏗️ Architecture Overview

The rebranding solution works by:

1. **Custom Build Configuration**: Uses a custom Buildroot configuration that pulls your rebranded containers instead of the official ones
2. **Rebranded Frontend**: Replaces "Home Assistant" with "Smartelligent Home" in the web interface
3. **Hybrid Approach**: Pulls official containers for supervisor, DNS, audio, etc., while using custom core and frontend
4. **Clean Integration**: Maintains the existing build system architecture

## 📁 Files Created

### Operating System Level
- `buildroot-external/configs/custom_generic_x86_64_defconfig` - Custom build configuration
- `buildroot-external/package/hassio/hassio-custom.mk` - Custom hassio package
- `buildroot-external/package/hassio/Config.in.custom` - Configuration options
- `buildroot-external/Config.in` - Updated to include custom config

### Frontend Rebranding
- `frontend/src/translations/en-rebranded.json` - Rebranded translation strings
- `frontend/src/html/index-rebranded.html.template` - Rebranded HTML template
- `frontend/src/state/panel-title-mixin-rebranded.ts` - Rebranded page titles

### Build Tools
- `scripts/build-rebranded.sh` - Automated build script

## 🚀 Quick Start

### Prerequisites
- Docker installed
- Node.js and npm (for frontend builds)
- Git
- Linux/macOS environment
- Access to GitHub Container Registry (ghcr.io/digital-synapse-sa)

### Automatic Configuration
This guide is pre-configured for:
- **Username**: `Digital-Synapse-SA`
- **Registry**: `ghcr.io/digital-synapse-sa`
- **Branch**: `dev-04072025`
- **No manual configuration required!**

### Step 1: Set Up Container Registry

You'll need access to push to your container registry. This guide is pre-configured for:
- **GitHub Container Registry**: `ghcr.io/digital-synapse-sa`
- **Branch**: `dev-04072025`

Make sure you're logged in to GitHub Container Registry:
```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u digital-synapse-sa --password-stdin
```

### Step 2: Build Custom Containers

```bash
# Build the custom containers (uses your registry and branch automatically)
./scripts/build-rebranded.sh containers
```

This will:
- Checkout the `dev-04072025` branch for both frontend and core
- Apply rebranding patches to the frontend
- Build the rebranded frontend
- Build a custom core container with the rebranded frontend
- Tag the container as `ghcr.io/digital-synapse-sa/generic-x86-64-homeassistant:2025.7.0-rebranded`

### Step 3: Push to Registry

```bash
# Push your custom container
docker push ghcr.io/digital-synapse-sa/generic-x86-64-homeassistant:2025.7.0-rebranded
```

### Step 4: Build Operating System

```bash
# Build the OS with your custom containers
./scripts/build-rebranded.sh os
```

This will:
- Automatically checkout the `dev-04072025` branch in the operating-system repository
- Build the operating system image
- Download official containers for supervisor, DNS, audio, etc.
- Use your custom core container instead of the official one
- Create a bootable image in `output/images/generic-x86-64.img`

## 🎨 Customization Options

### Branding Changes Made

1. **Application Name**: "Home Assistant" → "Smartelligent Home"
2. **System Hostname**: "homeassistant" → "smartelligent"
3. **Welcome Message**: "Welcome to Home Assistant" → "Welcome to Smartelligent Home"
4. **Page Titles**: All page titles now show "Smartelligent Home"
5. **Interface Text**: Key interface elements rebranded

### Additional Customizations

You can extend the rebranding by modifying:

#### More Translation Strings
Edit `frontend/src/translations/en-rebranded.json` to add more rebranded strings:

```json
{
  "ui": {
    "panel": {
      "config": {
        "info": {
          "your_custom_key": "Your Custom Text"
        }
      }
    }
  }
}
```

#### Visual Elements
- Replace logo in `frontend/src/html/index-rebranded.html.template`
- Update colors by modifying CSS variables
- Add custom icons by replacing files in `frontend/public/static/icons/`

#### System Branding
- Update `BR2_TARGET_GENERIC_HOSTNAME` in the config file
- Change `BR2_TARGET_GENERIC_ISSUE` for the login banner

## 🔧 Build Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CUSTOM_REGISTRY` | `ghcr.io/digital-synapse-sa` | Container registry URL |
| `CUSTOM_CORE_TAG` | `2025.7.0-rebranded` | Tag for your custom core image |
| `CUSTOM_MACHINE` | `generic-x86-64` | Machine type |
| `CUSTOM_ARCH` | `amd64` | Architecture |
| `BUILD_TARGET` | `custom-generic_x86_64` | Buildroot target |
| `BRANCH_NAME` | `dev-04072025` | Git branch to use for core and frontend |

### Build Targets

```bash
# Build just the frontend
cd frontend && npm run build

# Build just the core container
cd core && docker build -t my-core .

# Build the full OS
make custom-generic_x86_64

# Build with custom registry (if different from default)
CUSTOM_REGISTRY=my-registry.com ./scripts/build-rebranded.sh os
```

## 📋 What Gets Rebranded

### ✅ Rebranded Elements
- Web interface titles and headers
- System hostname and welcome message
- Page titles in browser tabs
- Key interface text mentioning "Home Assistant"
- Backup and restore interface
- Configuration panels
- Voice assistant references

### ❌ Not Rebranded (Uses Official)
- Add-on store (uses official supervisor)
- Integration names and descriptions
- Device drivers and hardware support
- Core functionality and APIs
- Documentation links

## 🔄 Update Process

To update your rebranded version:

1. **Pull latest changes**: `git pull origin main`
2. **Update version in script**: Edit `CUSTOM_CORE_TAG` in build script
3. **Rebuild containers**: `./scripts/build-rebranded.sh containers`
4. **Push to registry**: `docker push ...`
5. **Rebuild OS**: `./scripts/build-rebranded.sh os`

## 🐛 Troubleshooting

### Build Fails
```bash
# Check Docker is running
docker version

# Check Node.js version
node --version

# Clean build cache
rm -rf frontend/node_modules
rm -rf output/
```

### Container Not Found
```bash
# Verify your registry and tag
docker images | grep smartelligent

# Check if pushed to registry
docker pull ghcr.io/digital-synapse-sa/generic-x86-64-homeassistant:2025.7.0-rebranded
```

### Frontend Not Rebranded
```bash
# Check if rebranding files exist
ls -la frontend/src/translations/en-rebranded.json
ls -la frontend/src/html/index-rebranded.html.template

# Verify files were copied during build
grep -r "Smartelligent Home" frontend/build/
```

## 📚 Technical Details

### How It Works

1. **Buildroot Integration**: The custom hassio package modifies the version.json to point to your custom core image
2. **Container Replacement**: Only the core container is replaced; all other containers (supervisor, DNS, audio) remain official
3. **Frontend Patching**: Rebranding is applied by copying rebranded files over the originals before building
4. **Hybrid Architecture**: Maintains compatibility with the Home Assistant ecosystem while allowing customization

### Version Management

The system uses the same version management as Home Assistant:
- Pulls version info from `https://version.home-assistant.io/stable.json`
- Replaces only the core image URL and tag
- Maintains compatibility with supervisor and add-ons

## 🤝 Contributing

To contribute to this rebranding solution:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build process
5. Submit a pull request

## 📄 License

This rebranding solution maintains the same license as Home Assistant (Apache 2.0). The modifications are provided as-is for educational and personal use.

## 🆘 Support

For issues with this rebranding solution:
1. Check the troubleshooting section
2. Review the build logs
3. Verify your container registry setup
4. Test with a clean build environment

---

**Note**: This is a rebranding solution for Home Assistant. It maintains the same functionality while changing the visual branding. For production use, ensure you comply with all relevant licenses and terms of service. 
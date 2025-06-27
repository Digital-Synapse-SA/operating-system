# Smartelligent Container Configuration

This document explains how to configure Smartelligent OS to use custom repositories for different containers.

## Overview

Smartelligent OS supports variable repositories for all containers, allowing you to:

- Use custom repositories for main components (core, frontend, supervisor)
- Choose which supporting containers to customize (DNS, Audio, CLI, Multicast, Observer)
- Mix custom and standard containers for optimal stability and customization

## Container Types

### Main Components (Always Custom)
These components are always built from your custom repositories:
- **Core**: Home Assistant core application
- **Frontend**: Web interface
- **Supervisor**: Container management and system control

### Supporting Components (Configurable)
These components can be either custom or standard:
- **DNS**: DNS resolution service (dnsmasq)
- **Audio**: Audio handling service (PulseAudio)
- **CLI**: Command-line interface tools
- **Multicast**: Network discovery service (Avahi)
- **Observer**: System monitoring service

## Configuration Options

### 1. Default Configuration
```bash
./scripts/build-smartelligent.sh default
```
- Main components: Custom from Digital-Synapse-SA
- Supporting components: Standard Home Assistant containers
- **Recommended for most deployments**

### 2. Full Custom Configuration
```bash
./scripts/build-smartelligent.sh full
```
- All containers: Custom from Digital-Synapse-SA
- Maximum customization
- Requires all custom repositories to be available

### 3. Hybrid Configuration
```bash
./scripts/build-smartelligent.sh hybrid
```
- Main components: Custom from Digital-Synapse-SA
- Supporting components: Standard Home Assistant containers
- Same as default, but explicitly configured

### 4. Selective Configuration
```bash
./scripts/build-smartelligent.sh selective
```
- Main components: Custom from Digital-Synapse-SA
- Supporting components: Mix of custom and standard
- DNS, CLI, Observer: Custom
- Audio, Multicast: Standard

## Manual Configuration

You can manually edit the configuration file:

```bash
nano buildroot-external/package/hassio/smartelligent-containers.config
```

### Configuration Variables

```bash
# Main components (always custom)
SMARTELLIGENT_CORE_REPO="https://github.com/Digital-Synapse-SA/core.git"
SMARTELLIGENT_FRONTEND_REPO="https://github.com/Digital-Synapse-SA/frontend.git"
SMARTELLIGENT_SUPERVISOR_REPO="https://github.com/Digital-Synapse-SA/supervisor.git"

# Supporting components (configurable)
SMARTELLIGENT_USE_CUSTOM_DNS="y"  # or "n"
SMARTELLIGENT_DNS_REPO="https://github.com/Digital-Synapse-SA/dns.git"

SMARTELLIGENT_USE_CUSTOM_AUDIO="y"  # or "n"
SMARTELLIGENT_AUDIO_REPO="https://github.com/Digital-Synapse-SA/audio.git"

SMARTELLIGENT_USE_CUSTOM_CLI="y"  # or "n"
SMARTELLIGENT_CLI_REPO="https://github.com/Digital-Synapse-SA/cli.git"

SMARTELLIGENT_USE_CUSTOM_MULTICAST="y"  # or "n"
SMARTELLIGENT_MULTICAST_REPO="https://github.com/Digital-Synapse-SA/multicast.git"

SMARTELLIGENT_USE_CUSTOM_OBSERVER="y"  # or "n"
SMARTELLIGENT_OBSERVER_REPO="https://github.com/Digital-Synapse-SA/observer.git"
```

## Build Process

### 1. Configuration Loading
The build system loads configuration from `smartelligent-containers.config`:
- If file exists: Uses specified configuration
- If file doesn't exist: Uses default values

### 2. Container Building
For each container:
- **Custom containers**: Cloned from repository and built
- **Standard containers**: Built with Smartelligent branding
- **Fallback**: Uses official Home Assistant containers if custom build fails

### 3. Image Creation
All containers are packaged into the final OS image with:
- Custom branding throughout
- Proper container dependencies
- System integration

## Example Configurations

### Minimal Customization
```bash
# Only main components custom
SMARTELLIGENT_USE_CUSTOM_DNS="n"
SMARTELLIGENT_USE_CUSTOM_AUDIO="n"
SMARTELLIGENT_USE_CUSTOM_CLI="n"
SMARTELLIGENT_USE_CUSTOM_MULTICAST="n"
SMARTELLIGENT_USE_CUSTOM_OBSERVER="n"
```

### Maximum Customization
```bash
# All components custom
SMARTELLIGENT_USE_CUSTOM_DNS="y"
SMARTELLIGENT_USE_CUSTOM_AUDIO="y"
SMARTELLIGENT_USE_CUSTOM_CLI="y"
SMARTELLIGENT_USE_CUSTOM_MULTICAST="y"
SMARTELLIGENT_USE_CUSTOM_OBSERVER="y"
```

### Selective Customization
```bash
# Only specific components custom
SMARTELLIGENT_USE_CUSTOM_DNS="y"
SMARTELLIGENT_USE_CUSTOM_AUDIO="n"
SMARTELLIGENT_USE_CUSTOM_CLI="y"
SMARTELLIGENT_USE_CUSTOM_MULTICAST="n"
SMARTELLIGENT_USE_CUSTOM_OBSERVER="y"
```

## Troubleshooting

### Custom Repository Not Found
If a custom repository is not available:
1. The build system will try to build a standard container
2. If that fails, it will use the official Home Assistant container
3. Check the build logs for specific error messages

### Build Failures
Common issues and solutions:
- **Git clone fails**: Check repository URL and network connectivity
- **Docker build fails**: Ensure Docker is running and has sufficient resources
- **Dependency issues**: Check if required tools (yarn, git, docker) are installed

### Configuration Validation
The build system validates configuration:
- Required repository URLs when using custom containers
- Valid configuration values (y/n)
- Repository accessibility

## Best Practices

### 1. Start with Default Configuration
Begin with the default configuration for stability:
```bash
./scripts/build-smartelligent.sh default
```

### 2. Test Custom Components Individually
When adding custom supporting containers:
1. Test one component at a time
2. Verify the custom repository builds successfully
3. Ensure compatibility with the main system

### 3. Use Hybrid Approach for Production
For production deployments:
- Keep main components custom for branding
- Use standard supporting components for stability
- Only customize supporting components when necessary

### 4. Monitor Build Logs
Always check build logs for:
- Repository clone success/failure
- Container build status
- Configuration validation results

## Advanced Usage

### Custom Repository Structure
Your custom repositories should follow the same structure as the official ones:
- Include proper Dockerfile
- Maintain compatibility with Home Assistant
- Follow container best practices

### Version Management
- Use specific git tags or branches for reproducible builds
- Consider using release branches for stability
- Test with different Home Assistant versions

### CI/CD Integration
The configuration system supports CI/CD:
- Environment variables can override configuration
- Automated testing of different configurations
- Build matrix for multiple configurations 
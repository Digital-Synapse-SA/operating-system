# Smartelligent Container Configuration

This directory contains the configuration and build scripts for creating custom Smartelligent containers from Digital-Synapse-SA repositories.

## Configuration

The main configuration file is `smartelligent-containers.config`. It controls:

- **Main components** (always custom): core, frontend, supervisor
- **Supporting components** (configurable): dns, audio, cli, multicast, observer

## Current Configuration

### Main Components (Custom from Digital-Synapse-SA)
- **Core**: `https://github.com/Digital-Synapse-SA/core.git#dev-27062025`
- **Frontend**: `https://github.com/Digital-Synapse-SA/frontend.git#dev-27062025`
- **Supervisor**: `https://github.com/Digital-Synapse-SA/supervisor.git#dev-27062025`

### Supporting Components (Standard Home Assistant)
- **DNS**: Standard Home Assistant container
- **Audio**: Standard Home Assistant container
- **CLI**: Standard Home Assistant container
- **Multicast**: Standard Home Assistant container
- **Observer**: Standard Home Assistant container

## Scripts

### `build-smartelligent-containers.sh`
Main build script that:
1. Clones repositories from Digital-Synapse-SA
2. Builds Docker containers
3. Falls back to standard containers if custom builds fail
4. Saves containers as tar files

### `load-smartelligent-config.sh`
Loads and validates the configuration file, exports variables for the build process.

### `test-repositories.sh`
Tests if repositories and branches exist before building.

### `test-docker-build.sh`
Tests Docker build environment and base images.

## Usage

### Testing Configuration
```bash
# Test if repositories and branches exist
./test-repositories.sh

# Test Docker build environment
./test-docker-build.sh
```

### Building
The build process is integrated into the Buildroot build system. The configuration is automatically loaded and containers are built during the `hassio` package build.

### Customization

To customize the configuration:

1. **Change branches**: Edit `smartelligent-containers.config` and update the branch names after the `#` symbol
2. **Use custom supporting components**: Set `SMARTELLIGENT_USE_CUSTOM_*` to `y` and provide repository URLs
3. **Use standard components**: Set `SMARTELLIGENT_USE_CUSTOM_*` to `n`

## Fallback Behavior

If custom container builds fail, the system will:
1. Try to build a standard container with Smartelligent branding
2. If that fails, fall back to official Home Assistant container
3. Log the failure for debugging

## Troubleshooting

### Common Issues

1. **Branch not found**: Check available branches with `git ls-remote --heads <repo_url>`
2. **Docker build fails**: Check if required base images are available
3. **Repository not accessible**: Verify repository URLs and permissions

### Debugging

1. Run `./test-repositories.sh` to check repository access
2. Run `./test-docker-build.sh` to check Docker environment
3. Check build logs for specific error messages

## File Structure

```
hassio/
├── smartelligent-containers.config    # Main configuration
├── build-smartelligent-containers.sh  # Build script
├── load-smartelligent-config.sh       # Configuration loader
├── test-repositories.sh               # Repository tester
├── test-docker-build.sh               # Docker environment tester
└── README-smartelligent.md            # This file
``` 
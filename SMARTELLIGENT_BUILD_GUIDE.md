# Smartelligent Home Assistant OS Build Guide

This guide explains how to build a rebranded Home Assistant Operating System called "Smartelligent" for deployment on Intel mini PCs.

## Overview

Smartelligent is a rebranded version of Home Assistant OS with the following changes:
- System hostname: `smartelligent` (instead of `homeassistant`)
- Welcome message: "Welcome to Smartelligent"
- Web interface title: "Smartelligent" (instead of "Home Assistant")
- Component names: "Smartelligent Core", "Smartelligent Supervisor", "Smartelligent OS"
- Browser tab titles: "Smartelligent"

## Prerequisites

- macOS, Linux, or Windows with WSL
- Docker installed and running
- Git
- At least 20GB free disk space
- 8GB+ RAM recommended

## Build Process

### Step 1: Enter the Build Environment

```bash
# From the operating-system directory
./scripts/enter.sh
```

This will start a Docker container with all necessary build tools.

### Step 2: Build the Smartelligent Image

Inside the build container, run:

```bash
# Build the Smartelligent x86_64 image
make smartelligent_x86_64
```

Or use the convenience script:

```bash
./scripts/build-smartelligent.sh
```

### Step 3: Build the Frontend (Optional)

If you want to build the rebranded frontend separately:

```bash
./scripts/build-frontend-smartelligent.sh
```

## Build Output

The build process will create:
- `output/images/smartelligent_x86_64.img` - The bootable image file
- `output/images/smartelligent_x86_64.img.xz` - Compressed version

## Deployment

### Flashing to USB/SD Card

1. **Using Balena Etcher (Recommended)**:
   - Download and install Balena Etcher
   - Select the `smartelligent_x86_64.img` file
   - Select your target device
   - Click "Flash!"

2. **Using dd command (Linux/macOS)**:
   ```bash
   sudo dd if=output/images/smartelligent_x86_64.img of=/dev/sdX bs=4M status=progress
   ```
   Replace `/dev/sdX` with your actual device (be very careful with this command!)

### Installation on Mini PC

1. Insert the flashed USB drive into your Intel mini PC
2. Boot from USB (usually F12 or Del during boot)
3. The system will automatically install to the internal storage
4. Remove USB drive when prompted
5. System will reboot and start Smartelligent

## First Boot

1. Wait for the system to boot (may take 5-10 minutes on first boot)
2. Access the web interface at `http://smartelligent.local:8123`
3. Follow the setup wizard
4. Create your admin account

## Configuration

### Network Access

The system will be available at:
- `http://smartelligent.local:8123` (if mDNS works on your network)
- `http://[IP_ADDRESS]:8123` (check your router's DHCP table)

### SSH Access

SSH is disabled by default. To enable:
1. Go to Settings → System → Repairs
2. Click "Open Web Terminal"
3. Run: `ha os ssh enable`

## Customization

### Adding Custom Branding

To add your own logos or additional branding:

1. **Icons**: Replace files in `../frontend/public/static/icons/`
2. **Logos**: Update references in frontend components
3. **Colors**: Modify CSS variables in frontend styles

### System Configuration

The system uses the same configuration as Home Assistant OS:
- Configuration files in `/config/`
- Add-ons available through the Supervisor
- Full Home Assistant functionality

## Troubleshooting

### Build Issues

1. **Out of disk space**: Clean build with `make clean`
2. **Memory issues**: Increase Docker memory limit
3. **Network issues**: Check Docker network settings

### Boot Issues

1. **UEFI boot failure**: Ensure UEFI boot is enabled in BIOS
2. **No network**: Check network cable and DHCP settings
3. **Slow boot**: First boot is always slower, subsequent boots are faster

### Web Interface Issues

1. **Can't access web interface**: Check firewall settings
2. **SSL errors**: Use HTTP for initial setup
3. **Slow loading**: Check network connectivity

## Maintenance

### Updates

Smartelligent will receive updates through the standard Home Assistant update system:
1. Go to Settings → System → Updates
2. Install available updates
3. System will reboot automatically

### Backups

Always create backups before major updates:
1. Go to Settings → System → Backups
2. Create a full backup
3. Download and store safely

## Support

For issues specific to the Smartelligent build:
- Check the build logs in `output/logs/`
- Review the Home Assistant OS documentation
- Ensure you're using the latest build

## License

This build is based on Home Assistant OS which is licensed under Apache 2.0.
The Smartelligent branding modifications are provided as-is.

---

**Note**: This is a development build. For production use, ensure thorough testing and consider security implications of custom branding. 
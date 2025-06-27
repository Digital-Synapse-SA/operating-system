################################################################################
#
# HAOS
#
################################################################################

HASSIO_VERSION = 1.0.0
HASSIO_LICENSE = Apache License 2.0
# HASSIO_LICENSE_FILES = $(BR2_EXTERNAL_HASSOS_PATH)/../LICENSE
HASSIO_SITE = $(BR2_EXTERNAL_HASSOS_PATH)/package/hassio
HASSIO_SITE_METHOD = local
HASSIO_VERSION_URL = "https://version.home-assistant.io/"
ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_STABLE),y)
HASSIO_VERSION_CHANNEL = "stable"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_BETA),y)
HASSIO_VERSION_CHANNEL = "beta"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_DEV),y)
HASSIO_VERSION_CHANNEL = "dev"
endif

HASSIO_CONTAINER_IMAGES_ARCH = supervisor dns audio cli multicast observer core

# Load Smartelligent configuration
-include $(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/smartelligent-containers.config

# Default values if config file doesn't exist
SMARTELLIGENT_CORE_REPO ?= "https://github.com/Digital-Synapse-SA/core.git"
SMARTELLIGENT_FRONTEND_REPO ?= "https://github.com/Digital-Synapse-SA/frontend.git"
SMARTELLIGENT_SUPERVISOR_REPO ?= "https://github.com/Digital-Synapse-SA/supervisor.git"

# Default to standard containers for supporting components
SMARTELLIGENT_USE_CUSTOM_DNS ?= n
SMARTELLIGENT_USE_CUSTOM_AUDIO ?= n
SMARTELLIGENT_USE_CUSTOM_CLI ?= n
SMARTELLIGENT_USE_CUSTOM_MULTICAST ?= n
SMARTELLIGENT_USE_CUSTOM_OBSERVER ?= n

# Default repository URLs (empty if not using custom)
SMARTELLIGENT_DNS_REPO ?= ""
SMARTELLIGENT_AUDIO_REPO ?= ""
SMARTELLIGENT_CLI_REPO ?= ""
SMARTELLIGENT_MULTICAST_REPO ?= ""
SMARTELLIGENT_OBSERVER_REPO ?= ""

define HASSIO_CONFIGURE_CMDS
	# Load configuration and validate
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/load-smartelligent-config.sh
	
	# Create custom version.json with Smartelligent containers
	cat > $(@D)/version.json << 'EOF'
{
  "supervisor": "smartelligent/supervisor:latest",
  "core": "smartelligent/core:latest"
}
EOF

	# Add supporting containers based on configuration
ifeq ($(SMARTELLIGENT_USE_CUSTOM_DNS),y)
	echo '  "dns": "smartelligent/dns:latest",' >> $(@D)/version.json
else
	echo '  "dns": "ghcr.io/home-assistant/amd64-hassio-dns:latest",' >> $(@D)/version.json
endif

ifeq ($(SMARTELLIGENT_USE_CUSTOM_AUDIO),y)
	echo '  "audio": "smartelligent/audio:latest",' >> $(@D)/version.json
else
	echo '  "audio": "ghcr.io/home-assistant/amd64-hassio-audio:latest",' >> $(@D)/version.json
endif

ifeq ($(SMARTELLIGENT_USE_CUSTOM_CLI),y)
	echo '  "cli": "smartelligent/cli:latest",' >> $(@D)/version.json
else
	echo '  "cli": "ghcr.io/home-assistant/amd64-hassio-cli:latest",' >> $(@D)/version.json
endif

ifeq ($(SMARTELLIGENT_USE_CUSTOM_MULTICAST),y)
	echo '  "multicast": "smartelligent/multicast:latest",' >> $(@D)/version.json
else
	echo '  "multicast": "ghcr.io/home-assistant/amd64-hassio-multicast:latest",' >> $(@D)/version.json
endif

ifeq ($(SMARTELLIGENT_USE_CUSTOM_OBSERVER),y)
	echo '  "observer": "smartelligent/observer:latest"' >> $(@D)/version.json
else
	echo '  "observer": "ghcr.io/home-assistant/amd64-hassio-observer:latest"' >> $(@D)/version.json
endif

	echo '}' >> $(@D)/version.json
endef

define HASSIO_BUILD_CMDS
	$(Q)mkdir -p $(@D)/images
	$(Q)mkdir -p $(HASSIO_DL_DIR)
	
	# Build custom Smartelligent containers
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/build-smartelligent-containers.sh \
		"$(SMARTELLIGENT_CORE_REPO)" \
		"$(SMARTELLIGENT_FRONTEND_REPO)" \
		"$(SMARTELLIGENT_SUPERVISOR_REPO)" \
		"$(SMARTELLIGENT_DNS_REPO)" \
		"$(SMARTELLIGENT_AUDIO_REPO)" \
		"$(SMARTELLIGENT_CLI_REPO)" \
		"$(SMARTELLIGENT_MULTICAST_REPO)" \
		"$(SMARTELLIGENT_OBSERVER_REPO)" \
		"$(SMARTELLIGENT_USE_CUSTOM_DNS)" \
		"$(SMARTELLIGENT_USE_CUSTOM_AUDIO)" \
		"$(SMARTELLIGENT_USE_CUSTOM_CLI)" \
		"$(SMARTELLIGENT_USE_CUSTOM_MULTICAST)" \
		"$(SMARTELLIGENT_USE_CUSTOM_OBSERVER)" \
		"$(@D)/images" \
		"$(HASSIO_DL_DIR)"
	
	# Copy custom containers to expected locations or fetch standard ones
	$(foreach image,$(HASSIO_CONTAINER_IMAGES_ARCH),\
		cp "$(@D)/images/smartelligent-$(image).tar" "$(HASSIO_DL_DIR)/" 2>/dev/null || \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
			$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json $(image) "$(HASSIO_DL_DIR)" "$(@D)/images"
	)
endef

HASSIO_INSTALL_IMAGES = YES

define HASSIO_INSTALL_IMAGES_CMDS
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/create-data-partition.sh "$(@D)" "$(BINARIES_DIR)" "$(HASSIO_VERSION_CHANNEL)"
endef

$(eval $(generic-package))

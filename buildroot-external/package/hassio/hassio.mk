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

# Custom branding configuration
BR2_PACKAGE_HASSIO_CUSTOM_BRANDING ?= y
ifeq ($(BR2_PACKAGE_HASSIO_CUSTOM_BRANDING),y)
HASSIO_CUSTOM_CORE_REPO ?= "https://github.com/Digital-Synapse-SA/core.git"
HASSIO_CUSTOM_FRONTEND_REPO ?= "https://github.com/Digital-Synapse-SA/frontend.git"
HASSIO_CUSTOM_CORE_BRANCH ?= "ST-Branding-Stage1"
HASSIO_CUSTOM_FRONTEND_BRANCH ?= "ST-Branding-Stage1"
endif

ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_STABLE),y)
HASSIO_VERSION_CHANNEL = "stable"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_BETA),y)
HASSIO_VERSION_CHANNEL = "beta"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_DEV),y)
HASSIO_VERSION_CHANNEL = "dev"
endif

HASSIO_CONTAINER_IMAGES_ARCH = supervisor dns audio cli multicast observer core

define HASSIO_CONFIGURE_CMDS
	if [ "$(BR2_PACKAGE_HASSIO_CUSTOM_BRANDING)" = "y" ]; then \
		echo "Using custom smarTelligent branding..."; \
		echo "Fetching version info from $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL).json"; \
		if curl -s $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL)".json" > /tmp/version_raw.json; then \
			echo "Raw version data:"; \
			cat /tmp/version_raw.json; \
			jq '.core = "smartelligent_core_latest"' /tmp/version_raw.json > $(@D)/version.json; \
		else \
			echo "ERROR: Failed to fetch version data. Creating fallback version.json..."; \
			echo '{"core": "smartelligent_core_latest", "supervisor": "latest", "dns": "latest", "audio": "latest", "cli": "latest", "multicast": "latest", "observer": "latest", "images": {"supervisor": "ghcr.io/home-assistant/{arch}-hassio-supervisor", "dns": "ghcr.io/home-assistant/{arch}-hassio-dns", "audio": "ghcr.io/home-assistant/{arch}-hassio-audio", "cli": "ghcr.io/home-assistant/{arch}-hassio-cli", "multicast": "ghcr.io/home-assistant/{arch}-hassio-multicast", "observer": "ghcr.io/home-assistant/{arch}-hassio-observer"}}' > $(@D)/version.json; \
		fi; \
		echo "Created version.json with content:"; \
		cat $(@D)/version.json; \
		echo "Testing jq extraction for supervisor:"; \
		jq -e -r --arg image_json_name "supervisor" --arg arch "amd64" --arg machine "generic-x86-64" '.images[$image_json_name] | sub("{arch}"; $arch) | sub("{machine}"; $machine)' $(@D)/version.json || echo "ERROR: Failed to extract supervisor image name"; \
	else \
		curl -s $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL)".json" | jq '.core = "landingpage"' > $(@D)/version.json; \
	fi
endef

define HASSIO_BUILD_CMDS
	$(Q)mkdir -p $(@D)/images
	$(Q)mkdir -p $(HASSIO_DL_DIR)
	if [ "$(BR2_PACKAGE_HASSIO_CUSTOM_BRANDING)" = "y" ]; then \
		echo "Building custom smarTelligent core and frontend..."; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/build-custom-core.sh "$(@D)" "$(BR2_PACKAGE_HASSIO_ARCH)" "$(BR2_PACKAGE_HASSIO_MACHINE)"; \
		echo "Fetching other container images..."; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json supervisor "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json dns "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json audio "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json cli "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json multicast "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json observer "$(HASSIO_DL_DIR)" "$(@D)/images"; \
	else \
		echo "Fetching all container images normally..."; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json supervisor "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json dns "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json audio "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json cli "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json multicast "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json observer "$(HASSIO_DL_DIR)" "$(@D)/images"; \
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh $(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json core "$(HASSIO_DL_DIR)" "$(@D)/images"; \
	fi
endef

HASSIO_INSTALL_IMAGES = YES

define HASSIO_INSTALL_IMAGES_CMDS
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/create-data-partition.sh "$(@D)" "$(BINARIES_DIR)" "$(HASSIO_VERSION_CHANNEL)"
endef

$(eval $(generic-package))

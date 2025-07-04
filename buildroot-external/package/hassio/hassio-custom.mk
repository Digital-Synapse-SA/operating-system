################################################################################
#
# HAOS - Custom Rebranded Version
#
################################################################################

HASSIO_CUSTOM_VERSION = 1.0.0
HASSIO_CUSTOM_LICENSE = Apache License 2.0
HASSIO_CUSTOM_SITE = $(BR2_EXTERNAL_HASSOS_PATH)/package/hassio
HASSIO_CUSTOM_SITE_METHOD = local
HASSIO_CUSTOM_VERSION_URL = "https://version.home-assistant.io/"

# Configuration for custom images
HASSIO_CUSTOM_REGISTRY ?= "ghcr.io/digital-synapse-sa"
HASSIO_CUSTOM_CORE_IMAGE ?= "generic-x86-64-homeassistant"
HASSIO_CUSTOM_CORE_TAG ?= "2025.6.0-rebranded"

ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_STABLE),y)
HASSIO_CUSTOM_VERSION_CHANNEL = "stable"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_BETA),y)
HASSIO_CUSTOM_VERSION_CHANNEL = "beta"
else ifeq ($(BR2_PACKAGE_HASSIO_CHANNEL_DEV),y)
HASSIO_CUSTOM_VERSION_CHANNEL = "dev"
endif

# Include all container images except core (we'll use custom core)
HASSIO_CUSTOM_CONTAINER_IMAGES_ARCH = supervisor dns audio cli multicast observer

define HASSIO_CUSTOM_CONFIGURE_CMDS
	# Create custom version.json with our custom core image
	curl -s $(HASSIO_CUSTOM_VERSION_URL)$(HASSIO_CUSTOM_VERSION_CHANNEL)".json" > $(@D)/version.json
	# Update the core image reference to use our custom image
	jq '.core = "$(HASSIO_CUSTOM_CORE_TAG)"' $(@D)/version.json > $(@D)/version.json.tmp
	jq '.images.core = "$(HASSIO_CUSTOM_REGISTRY)/$(HASSIO_CUSTOM_CORE_IMAGE)"' $(@D)/version.json.tmp > $(@D)/version.json
	rm $(@D)/version.json.tmp
endef

define HASSIO_CUSTOM_BUILD_CMDS
	$(Q)mkdir -p $(@D)/images
	$(Q)mkdir -p $(HASSIO_DL_DIR)
	
	# Download standard images
	$(foreach image,$(HASSIO_CUSTOM_CONTAINER_IMAGES_ARCH),\
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
			$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json $(image) "$(HASSIO_DL_DIR)" "$(@D)/images"
	)
	
	# Download custom core image
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
		$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json core "$(HASSIO_DL_DIR)" "$(@D)/images"
endef

HASSIO_CUSTOM_INSTALL_IMAGES = YES

define HASSIO_CUSTOM_INSTALL_IMAGES_CMDS
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/create-data-partition.sh "$(@D)" "$(BINARIES_DIR)" "$(HASSIO_CUSTOM_VERSION_CHANNEL)"
endef

$(eval $(generic-package)) 
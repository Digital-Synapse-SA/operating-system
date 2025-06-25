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
HASSIO_CUSTOM_CORE_REPO ?= "https://github.com/wissamhamdach/core.git"
HASSIO_CUSTOM_FRONTEND_REPO ?= "https://github.com/wissamhamdach/frontend.git"
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
ifeq ($(BR2_PACKAGE_HASSIO_CUSTOM_BRANDING),y)
	# Use custom branding - build core from source
	@echo "Using custom Smartelligent branding..."
	# Create custom version.json with custom core
	curl -s $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL)".json" | \
		jq '.core = "smartelligent_core_latest"' > $(@D)/version.json
else
	# Deploy only landing page for "core" by setting version to "landingpage"
	curl -s $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL)".json" | jq '.core = "landingpage"' > $(@D)/version.json
endif
endef

define HASSIO_BUILD_CMDS
	$(Q)mkdir -p $(@D)/images
	$(Q)mkdir -p $(HASSIO_DL_DIR)
ifeq ($(BR2_PACKAGE_HASSIO_CUSTOM_BRANDING),y)
	# Build custom core and frontend
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/build-custom-core.sh \
		"$(@D)" "$(BR2_PACKAGE_HASSIO_ARCH)" "$(BR2_PACKAGE_HASSIO_MACHINE)"
	# Fetch other container images normally
	$(foreach image,supervisor dns audio cli multicast observer,\
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
			$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json $(image) "$(HASSIO_DL_DIR)" "$(@D)/images"
	)
else
	# Fetch all container images normally
	$(foreach image,$(HASSIO_CONTAINER_IMAGES_ARCH),\
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
			$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json $(image) "$(HASSIO_DL_DIR)" "$(@D)/images"
	)
endif
endef

HASSIO_INSTALL_IMAGES = YES

define HASSIO_INSTALL_IMAGES_CMDS
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/create-data-partition.sh "$(@D)" "$(BINARIES_DIR)" "$(HASSIO_VERSION_CHANNEL)"
endef

$(eval $(generic-package))

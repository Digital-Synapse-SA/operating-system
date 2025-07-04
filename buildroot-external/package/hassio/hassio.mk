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

# Support for custom container images
HASSIO_CUSTOM_REGISTRY ?= ""
HASSIO_CUSTOM_CORE_TAG ?= ""

HASSIO_CONTAINER_IMAGES_ARCH = supervisor dns audio cli multicast observer core

define HASSIO_CONFIGURE_CMDS
	# Download version information
	curl -s $(HASSIO_VERSION_URL)$(HASSIO_VERSION_CHANNEL)".json" > $(@D)/version.json.orig
	
	# Check if custom core image is specified
	if [ -n "$(HASSIO_CUSTOM_REGISTRY)" ] && [ -n "$(HASSIO_CUSTOM_CORE_TAG)" ]; then \
		echo "Using custom core image: $(HASSIO_CUSTOM_REGISTRY)/generic-x86-64-homeassistant:$(HASSIO_CUSTOM_CORE_TAG)"; \
		jq '.core = "$(HASSIO_CUSTOM_CORE_TAG)"' $(@D)/version.json.orig > $(@D)/version.json.tmp; \
		jq '.images.core = "$(HASSIO_CUSTOM_REGISTRY)/generic-x86-64-homeassistant"' $(@D)/version.json.tmp > $(@D)/version.json; \
		rm $(@D)/version.json.tmp; \
	else \
		echo "Using standard core configuration (landing page)"; \
		jq '.core = "landingpage"' $(@D)/version.json.orig > $(@D)/version.json; \
	fi
	
	rm $(@D)/version.json.orig
endef

define HASSIO_BUILD_CMDS
	$(Q)mkdir -p $(@D)/images
	$(Q)mkdir -p $(HASSIO_DL_DIR)
	$(foreach image,$(HASSIO_CONTAINER_IMAGES_ARCH),\
		$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/fetch-container-image.sh \
			$(BR2_PACKAGE_HASSIO_ARCH) $(BR2_PACKAGE_HASSIO_MACHINE) $(@D)/version.json $(image) "$(HASSIO_DL_DIR)" "$(@D)/images"
	)
endef

HASSIO_INSTALL_IMAGES = YES

define HASSIO_INSTALL_IMAGES_CMDS
	$(BR2_EXTERNAL_HASSOS_PATH)/package/hassio/create-data-partition.sh "$(@D)" "$(BINARIES_DIR)" "$(HASSIO_VERSION_CHANNEL)"
endef

$(eval $(generic-package))

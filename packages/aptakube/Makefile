PKG_NAME    := aptakube
PKG_VERSION     := 1.15.0

SHELL    := /bin/bash
ROOT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
BUILD_DIR := $(ROOT_DIR)/build
DL_DIR   := $(ROOT_DIR)/src/aptakube

ARCHES   := amd64

DL_BASE  := https://github.com/aptakube/aptakube/releases/download
deb_file  = aptakube_$(PKG_VERSION)_$(1).deb
dl_url    = $(DL_BASE)/$(PKG_VERSION)/$(call deb_file,$(1))

define DEB_ARCH_template
.PHONY: build-$(1)
build-$(1): fetch-$(1)
	@echo "==> Repacking $(PKG_NAME) for $(1)"
	cp $(DL_DIR)/$(call deb_file,$(1)) $(BUILD_DIR)/$(call deb_file,$(1))
	@echo "==> Ready $(BUILD_DIR)/$(call deb_file,$(1))"

.PHONY: fetch-$(1)
fetch-$(1):
	@mkdir -p $(DL_DIR)
	@if [ ! -f "$(DL_DIR)/$(call deb_file,$(1))" ]; then \
		echo "==> Downloading $(call dl_url,$(1))"; \
		curl -fSL -o "$(DL_DIR)/$(call deb_file,$(1))" "$(call dl_url,$(1))"; \
	fi
endef

$(foreach arch,$(ARCHES),$(eval $(call DEB_ARCH_template,$(arch))))

.PHONY: all
all: $(addprefix build-,$(ARCHES))

.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/$(PKG_NAME)_*.deb

.PHONY: distclean
distclean: clean
	rm -rf $(DL_DIR)

# Common build logic for Go-based .deb packages
# Each package Makefile must define:
#   PKG_NAME        - Debian package name
#   PKG_VERSION     - Package version (without leading v)
#   PKG_DESCRIPTION - Short description
#   PKG_HOMEPAGE    - Upstream URL
#   PKG_LICENSE     - License identifier
#   GIT_URL         - Git clone URL
#   GIT_TAG         - Git tag to checkout
#   GO_BUILD_CMD    - The go build command (use $(LDFLAGS_STR) and $(GO_PKG) placeholders)
#   GO_PKG          - Go package path to build (e.g. ./cmd/foo)
#   BINARY_NAME     - Output binary name
#   INSTALL_DIR     - Install directory inside package (e.g. /usr/bin)
#
# Optional:
#   PKG_MAINTAINER  - Maintainer field (default: package@daedaluz)
#   PKG_SECTION     - Debian section (default: devel)
#   PKG_PRIORITY    - Debian priority (default: optional)
#   PKG_DEPENDS     - Debian dependencies (default: empty)
#   CGO_ENABLED     - CGO toggle (default: 0)
#   EXTRA_BUILD_ENV - Extra env vars for go build
#   EXTRA_TAGS      - Extra build tags
#   EXTRA_GOFLAGS   - Extra flags passed to go build (e.g. -trimpath)
#   PRE_BUILD       - Commands to run before go build (inside source dir)
#   POST_INSTALL    - Hook to copy extra files into package tree
#   GO_TRIMPATH     - Set to empty to disable -trimpath (default: -trimpath)
#   BUILD_CMD       - Override the entire build command. Runs inside SRC_DIR.
#                     Use @@OUTPUT@@ as a placeholder for the output binary path.
#                     GOOS, GOARCH, GOARM are set as env vars automatically.
#
# Control scripts:
#   Place a debian/ directory next to the package Makefile containing any of:
#     preinst, postinst, prerm, postrm, conffiles, triggers, templates, config
#   These will be copied into DEBIAN/ and made executable (where appropriate).

SHELL := /bin/bash

ROOT_DIR    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SRC_DIR     := $(ROOT_DIR)/src/$(PKG_NAME)
BUILD_DIR   := $(ROOT_DIR)/build
PKG_DIR     := $(dir $(firstword $(MAKEFILE_LIST)))

ARCHES      ?= amd64 arm64 armhf
PKG_MAINTAINER ?= Tobias Assarsson <tobias.asssarsson@gmail.com>
PKG_SECTION    ?= devel
PKG_PRIORITY   ?= optional
PKG_DEPENDS    ?=
CGO_ENABLED    ?= 0
GO_TRIMPATH    ?= -trimpath

# Map Debian arch names to GOARCH
goarch_amd64 := amd64
goarch_arm64 := arm64
goarch_armhf := arm

GOARM_armhf  := 7

PKG_REVISION ?= 1

define DEB_ARCH_template
# $(1) = debian arch
.PHONY: build-$(1)
build-$(1): fetch
	@echo "==> Building $(PKG_NAME) for $(1)"
	rm -rf $(BUILD_DIR)/$(1)/pkg
	mkdir -p $(BUILD_DIR)/$(1)/pkg/$(INSTALL_DIR)
	mkdir -p $(BUILD_DIR)/$(1)/pkg/DEBIAN
	$(if $(BUILD_CMD),\
	cd $(SRC_DIR) && \
		GOOS=linux \
		GOARCH=$(goarch_$(1)) \
		$(if $(GOARM_$(1)),GOARM=$(GOARM_$(1)),) \
		$(subst @@OUTPUT@@,$(BUILD_DIR)/$(1)/pkg/$(INSTALL_DIR)/$(BINARY_NAME),$(BUILD_CMD)),\
	cd $(SRC_DIR) && \
		$(EXTRA_BUILD_ENV) \
		CGO_ENABLED=$(CGO_ENABLED) \
		GOOS=linux \
		GOARCH=$(goarch_$(1)) \
		$(if $(GOARM_$(1)),GOARM=$(GOARM_$(1)),) \
		go build \
			$(if $(EXTRA_TAGS),-tags '$(EXTRA_TAGS)',) \
			$(GO_TRIMPATH) \
			$(EXTRA_GOFLAGS) \
			-ldflags '$(LDFLAGS_STR)' \
			-o $(BUILD_DIR)/$(1)/pkg/$(INSTALL_DIR)/$(BINARY_NAME) \
			$(GO_PKG))
	$(if $(POST_INSTALL),cd $(SRC_DIR) && DEST=$(BUILD_DIR)/$(1)/pkg $(POST_INSTALL),)
	@echo "Package: $(PKG_NAME)" > $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Version: $(PKG_VERSION)-$(PKG_REVISION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Architecture: $(1)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Maintainer: $(PKG_MAINTAINER)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Section: $(PKG_SECTION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Priority: $(PKG_PRIORITY)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Homepage: $(PKG_HOMEPAGE)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Description: $(PKG_DESCRIPTION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	$(if $(PKG_DEPENDS),@echo "Depends: $(PKG_DEPENDS)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control,)
	@if [ -d "$(PKG_DIR)debian" ]; then \
		cp -a $(PKG_DIR)debian/* $(BUILD_DIR)/$(1)/pkg/DEBIAN/; \
		for f in $(BUILD_DIR)/$(1)/pkg/DEBIAN/pre* $(BUILD_DIR)/$(1)/pkg/DEBIAN/post* $(BUILD_DIR)/$(1)/pkg/DEBIAN/config; do \
			[ -f "$$f" ] && chmod 755 "$$f" || true; \
		done; \
	fi
	dpkg-deb --build --root-owner-group $(BUILD_DIR)/$(1)/pkg \
		$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_REVISION)_$(1).deb
	@echo "==> Built $(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_REVISION)_$(1).deb"
endef

$(foreach arch,$(ARCHES),$(eval $(call DEB_ARCH_template,$(arch))))

.PHONY: fetch
fetch:
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "==> Cloning $(GIT_URL) @ $(GIT_TAG)"; \
		git clone --depth 1 --branch $(GIT_TAG) $(GIT_URL) $(SRC_DIR); \
	fi
	@git config --global --get-all safe.directory | grep -qxF '$(SRC_DIR)' || \
		git config --global --add safe.directory '$(SRC_DIR)'
	$(if $(PRE_BUILD),cd $(SRC_DIR) && $(PRE_BUILD),)

.PHONY: all
all: $(addprefix build-,$(ARCHES))

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*/pkg
	rm -f $(BUILD_DIR)/*.deb

.PHONY: distclean
distclean: clean
	rm -rf $(SRC_DIR)

PKG_NAME        := golang
PKG_VERSION     := 1.26.1
PKG_EPOCH       := 2
PKG_REVISION    := 2
PKG_DESCRIPTION := The Go programming language
PKG_HOMEPAGE    := https://go.dev
PKG_LICENSE     := BSD-3-Clause
PKG_MAINTAINER  := package@daedaluz
PKG_SECTION     := devel
PKG_PRIORITY    := optional

INSTALL_DIR     := /usr/local

SHELL   := /bin/bash
ROOT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
BUILD_DIR := $(ROOT_DIR)/build
DL_DIR   := $(ROOT_DIR)/src/golang

ARCHES  ?= amd64 arm64 armhf

DL_BASE := https://go.dev/dl

# Map Debian arch to Go download arch
dlarch_amd64 := amd64
dlarch_arm64 := arm64
dlarch_armhf := armv6l

tarball = go$(PKG_VERSION).linux-$(dlarch_$(1)).tar.gz
dl_url  = $(DL_BASE)/$(call tarball,$(1))

define DEB_ARCH_template
.PHONY: build-$(1)
build-$(1): fetch-$(1)
	@echo "==> Packaging golang for $(1)"
	rm -rf $(BUILD_DIR)/$(1)/pkg
	mkdir -p $(BUILD_DIR)/$(1)/pkg/$(INSTALL_DIR)
	mkdir -p $(BUILD_DIR)/$(1)/pkg/DEBIAN
	mkdir -p $(BUILD_DIR)/$(1)/pkg/etc/profile.d
	tar -xzf $(DL_DIR)/$(call tarball,$(1)) -C $(BUILD_DIR)/$(1)/pkg/$(INSTALL_DIR)
	mkdir -p $(BUILD_DIR)/$(1)/pkg/usr/bin
	ln -sf /usr/local/go/bin/go $(BUILD_DIR)/$(1)/pkg/usr/bin/go
	ln -sf /usr/local/go/bin/gofmt $(BUILD_DIR)/$(1)/pkg/usr/bin/gofmt
	@echo "Package: $(PKG_NAME)" > $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Version: $(PKG_EPOCH):$(PKG_VERSION)-$(PKG_REVISION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Architecture: $(1)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Maintainer: $(PKG_MAINTAINER)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Section: $(PKG_SECTION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Priority: $(PKG_PRIORITY)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Homepage: $(PKG_HOMEPAGE)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Description: $(PKG_DESCRIPTION)" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Conflicts: golang-go, golang-src, golang-doc" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Provides: golang-go, golang-src, golang-doc" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	@echo "Replaces: golang-go, golang-src, golang-doc" >> $(BUILD_DIR)/$(1)/pkg/DEBIAN/control
	dpkg-deb --build --root-owner-group $(BUILD_DIR)/$(1)/pkg \
		$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_REVISION)_$(1).deb
	@echo "==> Built $(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_REVISION)_$(1).deb"

.PHONY: fetch-$(1)
fetch-$(1):
	@mkdir -p $(DL_DIR)
	@if [ ! -f "$(DL_DIR)/$(call tarball,$(1))" ]; then \
		echo "==> Downloading $(call dl_url,$(1))"; \
		curl -fSL -o "$(DL_DIR)/$(call tarball,$(1))" "$(call dl_url,$(1))"; \
	fi
endef

$(foreach arch,$(ARCHES),$(eval $(call DEB_ARCH_template,$(arch))))

.PHONY: all
all: $(addprefix build-,$(ARCHES))

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*/pkg
	rm -f $(BUILD_DIR)/$(PKG_NAME)_*.deb

.PHONY: distclean
distclean: clean
	rm -rf $(DL_DIR)

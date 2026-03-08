PKG_NAME        := k9s
PKG_VERSION     := 0.50.18
PKG_DESCRIPTION := Kubernetes CLI to manage your clusters in style
PKG_HOMEPAGE    := https://github.com/derailed/k9s
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/derailed/k9s.git
GIT_TAG         := v$(PKG_VERSION)

BINARY_NAME     := k9s
INSTALL_DIR     := /usr/bin

# Delegate to upstream's make build, passing OUTPUT_BIN for the output path.
# Upstream Makefile handles ldflags, tags (netgo), CGO_ENABLED, etc.
BUILD_CMD       = $(MAKE) -f Makefile build OUTPUT_BIN=@@OUTPUT@@ VERSION=v$(PKG_VERSION)

include ../../common.mk

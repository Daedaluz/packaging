PKG_NAME        := k9s
PKG_VERSION     := 0.50.18
PKG_DESCRIPTION := Kubernetes CLI to manage your clusters in style
PKG_HOMEPAGE    := https://github.com/derailed/k9s
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/derailed/k9s.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := .
BINARY_NAME     := k9s
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

GIT_REV         := $(shell [ -d "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/k9s" ] && cd "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/k9s" && git rev-parse --short HEAD || echo "unknown")
BUILD_DATE      := $(shell date -u +%FT%TZ)

LDFLAGS_STR     := -w -s \
	-X github.com/derailed/k9s/cmd.version=$(PKG_VERSION) \
	-X github.com/derailed/k9s/cmd.commit=$(GIT_REV) \
	-X github.com/derailed/k9s/cmd.date=$(BUILD_DATE)

include ../../common.mk

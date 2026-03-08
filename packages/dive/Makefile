PKG_NAME        := dive
PKG_VERSION     := 0.13.1
PKG_DESCRIPTION := A tool for exploring Docker image layers and optimizing image size
PKG_HOMEPAGE    := https://github.com/wagoodman/dive
PKG_LICENSE     := MIT

GIT_URL         := https://github.com/wagoodman/dive.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := .
BINARY_NAME     := dive
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

SRC_BASE        := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/dive
GIT_COMMIT      := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && git rev-parse --short HEAD || echo "unknown")
BUILD_DATE      := $(shell date -u +%FT%TZ)

LDFLAGS_STR     := -w -s \
	-X main.version=$(PKG_VERSION) \
	-X main.commit=$(GIT_COMMIT) \
	-X main.buildTime=$(BUILD_DATE)

include ../../common.mk

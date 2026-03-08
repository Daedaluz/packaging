PKG_NAME        := golangci-lint
PKG_VERSION     := 2.11.2
PKG_DESCRIPTION := Fast linters runner for Go
PKG_HOMEPAGE    := https://github.com/golangci/golangci-lint
PKG_LICENSE     := GPL-3.0

GIT_URL         := https://github.com/golangci/golangci-lint.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/golangci-lint
BINARY_NAME     := golangci-lint
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

GIT_REV         := $(shell [ -d "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/golangci-lint" ] && cd "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/golangci-lint" && git rev-parse --short HEAD || echo "unknown")
BUILD_DATE      := $(shell date -u +%FT%TZ)

LDFLAGS_STR     := -s -w \
	-X main.version=$(PKG_VERSION) \
	-X main.commit=$(GIT_REV) \
	-X main.date=$(BUILD_DATE)

include ../../common.mk

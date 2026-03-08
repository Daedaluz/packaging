PKG_NAME        := gh
PKG_VERSION     := 2.87.3
PKG_DESCRIPTION := GitHub CLI
PKG_HOMEPAGE    := https://cli.github.com
PKG_LICENSE     := MIT

GIT_URL         := https://github.com/cli/cli.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/gh
BINARY_NAME     := gh
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

BUILD_DATE      := $(shell date -u +%Y-%m-%d)

LDFLAGS_STR     := -s -w \
	-X github.com/cli/cli/v2/internal/build.Version=$(PKG_VERSION) \
	-X github.com/cli/cli/v2/internal/build.Date=$(BUILD_DATE)

include ../../common.mk

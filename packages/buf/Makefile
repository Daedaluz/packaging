PKG_NAME        := buf
PKG_VERSION     := 1.66.0
PKG_DESCRIPTION := The best way to work with Protocol Buffers
PKG_HOMEPAGE    := https://buf.build
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/bufbuild/buf.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/buf
BINARY_NAME     := buf
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

LDFLAGS_STR     := -s -w

EXTRA_GOFLAGS   := -buildvcs=false

include ../../common.mk

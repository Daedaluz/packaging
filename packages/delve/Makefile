PKG_NAME        := delve
PKG_VERSION     := 1.26.1
PKG_DESCRIPTION := Debugger for the Go programming language
PKG_HOMEPAGE    := https://github.com/go-delve/delve
PKG_LICENSE     := MIT

GIT_URL         := https://github.com/go-delve/delve.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/dlv
BINARY_NAME     := dlv
INSTALL_DIR     := /usr/bin

GIT_REV         := $(shell [ -d "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/delve" ] && cd "$(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/delve" && git rev-parse HEAD || echo "unknown")

LDFLAGS_STR     := -X main.Build=$(GIT_REV) -extldflags -static
GO_TRIMPATH     :=
ARCHES          := amd64 arm64

include ../../common.mk

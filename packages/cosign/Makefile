PKG_NAME        := cosign
PKG_VERSION     := 3.0.5
PKG_DESCRIPTION := Container signing, verification and storage in an OCI registry
PKG_HOMEPAGE    := https://github.com/sigstore/cosign
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/sigstore/cosign.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/cosign
BINARY_NAME     := cosign
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

SRC_BASE        := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/cosign
GIT_COMMIT      := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && git rev-parse HEAD || echo "unknown")
GIT_TREE_STATE  := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && (test -z "$$(git status --porcelain)" && echo "clean" || echo "dirty") || echo "unknown")
BUILD_DATE      := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

VERSION_PKG     := sigs.k8s.io/release-utils/version

LDFLAGS_STR     := -s -w -buildid= \
	-X $(VERSION_PKG).gitVersion=v$(PKG_VERSION) \
	-X $(VERSION_PKG).gitCommit=$(GIT_COMMIT) \
	-X $(VERSION_PKG).gitTreeState=$(GIT_TREE_STATE) \
	-X $(VERSION_PKG).buildDate=$(BUILD_DATE)

include ../../common.mk

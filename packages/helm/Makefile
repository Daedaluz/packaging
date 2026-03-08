PKG_NAME        := helm
PKG_VERSION     := 4.1.1
PKG_DESCRIPTION := The Kubernetes Package Manager
PKG_HOMEPAGE    := https://helm.sh
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/helm/helm.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/helm
BINARY_NAME     := helm
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

SRC_BASE        := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/helm
GIT_COMMIT      := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && git rev-parse HEAD || echo "unknown")
GIT_TREE_STATE  := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && (test -z "$$(git status --porcelain)" && echo "clean" || echo "dirty") || echo "unknown")

LDFLAGS_STR     := -w -s \
	-X helm.sh/helm/v3/internal/version.version=v$(PKG_VERSION) \
	-X helm.sh/helm/v3/internal/version.metadata= \
	-X helm.sh/helm/v3/internal/version.gitCommit=$(GIT_COMMIT) \
	-X helm.sh/helm/v3/internal/version.gitTreeState=$(GIT_TREE_STATE)

include ../../common.mk

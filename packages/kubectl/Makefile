PKG_NAME        := kubectl
PKG_VERSION     := 1.35.2
PKG_DESCRIPTION := Kubernetes command-line tool
PKG_HOMEPAGE    := https://kubernetes.io
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/kubernetes/kubernetes.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/kubectl
BINARY_NAME     := kubectl
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

SRC_BASE        := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../../src/kubectl

GIT_COMMIT      := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && git rev-parse HEAD || echo "unknown")
GIT_TREE_STATE  := $(shell [ -d "$(SRC_BASE)" ] && cd "$(SRC_BASE)" && (test -z "$$(git status --porcelain)" && echo "clean" || echo "dirty") || echo "unknown")
GIT_MAJOR       := $(word 1,$(subst ., ,$(PKG_VERSION)))
GIT_MINOR       := $(word 2,$(subst ., ,$(PKG_VERSION)))
BUILD_DATE      := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

VERSION_PKG     := k8s.io/component-base/version
CLIENT_PKG      := k8s.io/client-go/pkg/version

LDFLAGS_STR     := -w -s \
	-X $(VERSION_PKG).buildDate=$(BUILD_DATE) \
	-X $(VERSION_PKG).gitCommit=$(GIT_COMMIT) \
	-X $(VERSION_PKG).gitTreeState=$(GIT_TREE_STATE) \
	-X $(VERSION_PKG).gitVersion=v$(PKG_VERSION) \
	-X $(VERSION_PKG).gitMajor=$(GIT_MAJOR) \
	-X $(VERSION_PKG).gitMinor=$(GIT_MINOR) \
	-X $(CLIENT_PKG).buildDate=$(BUILD_DATE) \
	-X $(CLIENT_PKG).gitCommit=$(GIT_COMMIT) \
	-X $(CLIENT_PKG).gitTreeState=$(GIT_TREE_STATE) \
	-X $(CLIENT_PKG).gitVersion=v$(PKG_VERSION) \
	-X $(CLIENT_PKG).gitMajor=$(GIT_MAJOR) \
	-X $(CLIENT_PKG).gitMinor=$(GIT_MINOR)

include ../../common.mk

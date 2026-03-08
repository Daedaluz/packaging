PKG_NAME        := crane
PKG_VERSION     := 0.20.3
PKG_DESCRIPTION := A tool for managing container images
PKG_HOMEPAGE    := https://github.com/google/go-containerregistry
PKG_LICENSE     := Apache-2.0

GIT_URL         := https://github.com/google/go-containerregistry.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/crane
BINARY_NAME     := crane
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

LDFLAGS_STR     := -s -w \
	-X github.com/google/go-containerregistry/cmd/crane/cmd.Version=$(PKG_VERSION) \
	-X github.com/google/go-containerregistry/pkg/v1/remote/transport.Version=$(PKG_VERSION)

include ../../common.mk

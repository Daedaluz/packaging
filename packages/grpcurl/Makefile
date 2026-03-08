PKG_NAME        := grpcurl
PKG_VERSION     := 1.9.3
PKG_DESCRIPTION := Like cURL, but for gRPC
PKG_HOMEPAGE    := https://github.com/fullstorydev/grpcurl
PKG_LICENSE     := MIT

GIT_URL         := https://github.com/fullstorydev/grpcurl.git
GIT_TAG         := v$(PKG_VERSION)

GO_PKG          := ./cmd/grpcurl
BINARY_NAME     := grpcurl
INSTALL_DIR     := /usr/bin
CGO_ENABLED     := 0

LDFLAGS_STR     := -s -w \
	-X main.version=v$(PKG_VERSION)

include ../../common.mk

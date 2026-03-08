PACKAGES := k9s delve gops golangci-lint golang helm kubectl dive crane cobra-cli grpcurl aptakube gh cosign
BUILD_DIR := $(CURDIR)/build

-include .env

.PHONY: all clean distclean upload check-updates update-versions deps $(PACKAGES)

all: $(PACKAGES)

$(PACKAGES):
	$(MAKE) -C packages/$@ all

clean:
	@for pkg in $(PACKAGES); do \
		$(MAKE) -C packages/$$pkg clean; \
	done

distclean:
	@for pkg in $(PACKAGES); do \
		$(MAKE) -C packages/$$pkg distclean; \
	done

# Build a single package for a single arch:
#   make k9s ARCHES=amd64
$(PACKAGES:%=%-amd64): %-amd64:
	$(MAKE) -C packages/$* build-amd64

$(PACKAGES:%=%-arm64): %-arm64:
	$(MAKE) -C packages/$* build-arm64

$(PACKAGES:%=%-armhf): %-armhf:
	$(MAKE) -C packages/$* build-armhf

# Install build dependencies.
deps:
	sudo apt-get update
	sudo apt-get install -y build-essential git curl dpkg-dev python3 gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu

# Check for new upstream versions.
check-updates:
	@$(CURDIR)/scripts/check-updates.sh

# Check and update Makefiles with new versions.
update-versions:
	@$(CURDIR)/scripts/check-updates.sh --update

# Upload all .deb files in build/ to aptly and add them to the repo.
# Requires .env with APTLY_URL, APTLY_USER, APTLY_PASS, APTLY_REPO.
CURL_AUTH = -u $(APTLY_USER):$(APTLY_PASS)
UPLOAD_DIR = packaging-$(shell date +%s)
APTLY_REPO_ENC = $(shell printf '%s' '$(APTLY_REPO)' | python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.stdin.read(),safe=""))')

upload:
	@test -n "$(APTLY_URL)" || { echo "error: APTLY_URL not set. Copy .env.example to .env and fill it in."; exit 1; }
	@test -n "$(APTLY_REPO)" || { echo "error: APTLY_REPO not set."; exit 1; }
	@debs=$$(find $(BUILD_DIR) -name '*.deb' 2>/dev/null); \
	if [ -z "$$debs" ]; then echo "error: no .deb files found in $(BUILD_DIR)/"; exit 1; fi
	@echo "==> Uploading .deb files to $(APTLY_URL) (dir: $(UPLOAD_DIR))"
	@for deb in $(BUILD_DIR)/*.deb; do \
		echo "    $$deb"; \
		curl -fsSL $(CURL_AUTH) -X POST -F file=@$$deb \
			$(APTLY_URL)/api/files/$(UPLOAD_DIR) || exit 1; \
		echo; \
	done
	@echo "==> Adding uploaded files to repo '$(APTLY_REPO)'"
	curl -fsSL $(CURL_AUTH) -X POST \
		$(APTLY_URL)/api/repos/$(APTLY_REPO_ENC)/file/$(UPLOAD_DIR)?forceReplace=1
	@echo
	@echo "==> Done. You may need to update your published repo."

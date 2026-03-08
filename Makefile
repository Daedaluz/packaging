PACKAGES := k9s delve gops golangci-lint golang helm kubectl dive crane cobra-cli grpcurl aptakube gh cosign buf
BUILD_DIR := $(CURDIR)/build

-include .env

.PHONY: all clean distclean upload publish check-updates update-versions auto-update deps $(PACKAGES)

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
	apt-get update
	apt-get install -y build-essential golang/dev git curl dpkg-dev python3 gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu
	apt-get upgrade -y

# Check for new upstream versions.
check-updates:
	@$(CURDIR)/scripts/check-updates.sh

# Check and update Makefiles with new versions.
update-versions:
	@$(CURDIR)/scripts/check-updates.sh --update

# Pull, check for updates, commit and push if any found.
auto-update:
	@$(CURDIR)/scripts/auto-update.sh

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
	@echo "==> Done. Run 'make publish' to update the published repo."

# Update the published repository.
# Requires APTLY_PUBLISH_PREFIX in .env (use "." for the root prefix).
APTLY_PREFIX_ENC = $(shell printf '%s' '$(APTLY_PUBLISH_PREFIX)' | python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.stdin.read(),safe=""))')

publish:
	@test -n "$(APTLY_URL)" || { echo "error: APTLY_URL not set."; exit 1; }
	@test -n "$(APTLY_PUBLISH_PREFIX)" || { echo "error: APTLY_PUBLISH_PREFIX not set."; exit 1; }
	@test -n "$(APTLY_PUBLISH_DIST)" || { echo "error: APTLY_PUBLISH_DIST not set."; exit 1; }
	@echo "==> Updating published repo (prefix: $(APTLY_PUBLISH_PREFIX), dist: $(APTLY_PUBLISH_DIST))"
	curl -fsSL $(CURL_AUTH) -X PUT \
		-H 'Content-Type: application/json' \
		-d '{"ForceOverwrite": true}' \
		$(APTLY_URL)/api/publish/$(APTLY_PREFIX_ENC)/$(APTLY_PUBLISH_DIST)
	@echo
	@echo "==> Published repo updated."

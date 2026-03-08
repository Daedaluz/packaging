#!/bin/bash
# Build and push the CI Docker image.
# Usage:
#   ./scripts/build-image.sh
#   IMAGE=ghcr.io/daedaluz/go-deb-ci:v2 ./scripts/build-image.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

IMAGE="${IMAGE:-ghcr.io/daedaluz/go-deb-ci:latest}"

echo "==> Building $IMAGE"
docker build  -t "$IMAGE" "$ROOT_DIR"

echo "==> Pushing $IMAGE"
docker push "$IMAGE"

echo "==> Done."

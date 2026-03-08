#!/bin/bash
# CI script: install deps, check for updates, build, upload, and publish.
# Expects .env to be present (or env vars set externally).
# Usage:
#   ./scripts/ci.sh [directory]
#
# If directory is given and does not contain the repo, it will be cloned there.
# Defaults to the current working directory.

set -euo pipefail

if [ -n "${SSH_CLONE:-}" ]; then
    REPO_URL="git@github.com:daedaluz/packaging.git"
else
    REPO_URL="https://github.com/daedaluz/packaging.git"
fi
WORK_DIR="${1:-}"

# If a directory argument is given, clone/pull there and re-exec its copy of ci.sh
if [ -n "$WORK_DIR" ]; then
    if [ ! -f "$WORK_DIR/Makefile" ]; then
        echo "==> Cloning $REPO_URL into $WORK_DIR"
        git clone "$REPO_URL" "$WORK_DIR"
    fi
    cd "$WORK_DIR"
    git pull --ff-only
    exec ./scripts/ci.sh
fi

gh auth status

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# 1. Install build dependencies
echo "==> Installing dependencies"
make deps

echo ""
echo "==> Checking for upstream updates"
UPDATED_FILE=$(mktemp)
trap 'rm -f "$UPDATED_FILE"' EXIT

"$SCRIPT_DIR/check-updates.sh" --update 3>"$UPDATED_FILE"

if [ ! -s "$UPDATED_FILE" ]; then
    echo "==> No updates found. Nothing to do."
    exit 0
fi

# 3. Commit version bumps
echo ""
echo "==> Updates found, committing"
SUBJECT_PARTS=()
BODY_LINES=()
UPDATED_PKGS=()

while read -r pkg old new; do
    [ -z "$pkg" ] && continue
    SUBJECT_PARTS+=("$pkg $new")
    BODY_LINES+=("- $pkg: $old -> $new")
    UPDATED_PKGS+=("$pkg")
done < "$UPDATED_FILE"

if [ "${#SUBJECT_PARTS[@]}" -eq 1 ]; then
    SUBJECT="Update ${SUBJECT_PARTS[0]}"
else
    SUBJECT="Update $(printf '%s, ' "${SUBJECT_PARTS[@]}" | sed 's/, $//')"
fi

BODY=$(printf '%s\n' "${BODY_LINES[@]}")

git add packages/*/Makefile
git commit -m "$SUBJECT" -m "$BODY"
git push

# 4. Clean build directory and build only updated packages
echo ""
echo "==> Cleaning build directory"
rm -rf build/

echo "==> Building updated packages: ${UPDATED_PKGS[*]}"
for pkg in "${UPDATED_PKGS[@]}"; do
    make -C "packages/$pkg" distclean
    make "$pkg"
done

# 5. Upload and publish
echo ""
echo "==> Uploading to aptly"
make upload

echo ""
echo "==> Publishing"
make publish

echo ""
echo "==> CI complete."

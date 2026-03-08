#!/bin/bash
# Pull latest changes, check for upstream version updates, commit and push.
# Usage:
#   ./scripts/auto-update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Pull latest changes
echo "==> Pulling latest changes"
git pull --ff-only

# Run check-updates with --update, capturing the list of updated packages via fd 3
echo "==> Checking for upstream updates"
UPDATED_FILE=$(mktemp)
trap 'rm -f "$UPDATED_FILE"' EXIT

"$SCRIPT_DIR/check-updates.sh" --update 3>"$UPDATED_FILE"

if [ ! -s "$UPDATED_FILE" ]; then
    echo "==> Everything is up to date."
    exit 0
fi

# Build commit message from the updated list
echo ""
echo "==> Updates found:"
SUBJECT_PARTS=()
BODY_LINES=()

while read -r pkg old new; do
    [ -z "$pkg" ] && continue
    echo "  $pkg: $old -> $new"
    SUBJECT_PARTS+=("$pkg $new")
    BODY_LINES+=("- $pkg: $old -> $new")
done < "$UPDATED_FILE"

# Construct commit message
if [ "${#SUBJECT_PARTS[@]}" -eq 1 ]; then
    SUBJECT="Update ${SUBJECT_PARTS[0]}"
else
    SUBJECT="Update $(printf '%s, ' "${SUBJECT_PARTS[@]}" | sed 's/, $//')"
fi

BODY=$(printf '%s\n' "${BODY_LINES[@]}")

# Stage, commit, and push
echo ""
echo "==> Committing changes"
git add packages/*/Makefile
git commit -m "$SUBJECT" -m "$BODY"

echo "==> Pushing"
git push

echo "==> Done."

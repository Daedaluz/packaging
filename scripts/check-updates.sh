#!/bin/bash
# Check for new versions of all packages and optionally update Makefiles.
# Usage:
#   ./scripts/check-updates.sh              # check only
#   ./scripts/check-updates.sh --update     # check and update Makefiles
#   ./scripts/check-updates.sh <pkg>        # check a single package
#   ./scripts/check-updates.sh --update <pkg>  # update a single package

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$ROOT_DIR/packages"

UPDATE=false
FILTER=""

for arg in "$@"; do
    case "$arg" in
        --update) UPDATE=true ;;
        *) FILTER="$arg" ;;
    esac
done

red()    { printf '\033[31m%s\033[0m' "$1"; }
green()  { printf '\033[32m%s\033[0m' "$1"; }
yellow() { printf '\033[33m%s\033[0m' "$1"; }
bold()   { printf '\033[1m%s\033[0m' "$1"; }

# Compare two semver strings. Returns 0 if $1 >= $2, 1 otherwise.
version_gte() {
    local v1="$1" v2="$2"
    [ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -1)" = "$v1" ]
}

# Get latest version from GitHub releases for a given owner/repo.
# Checks both releases and tags, returns the highest semver.
gh_latest_version() {
    local repo="$1"
    local release_tag="" tag_tag="" best=""

    # Try latest stable GitHub release (exclude pre-releases)
    release_tag=$(gh release list --repo "$repo" --limit 10 --json tagName,isPrerelease \
        --jq '[.[] | select(.isPrerelease | not) | .tagName] | .[0] // empty' 2>/dev/null) || true
    release_tag="${release_tag#v}"

    # Also check latest tag (some repos tag without creating releases)
    # Filter out pre-release versions (alpha, beta, rc, dev)
    tag_tag=$(gh api "repos/$repo/tags?per_page=50" --jq '
        [.[].name
         | select(test("^v?[0-9]+\\.[0-9]+"))
         | select(test("alpha|beta|rc|dev|pre") | not)]
        | map(ltrimstr("v"))
        | sort_by(split(".") | map(tonumber? // 0))
        | reverse
        | .[0] // empty
    ' 2>/dev/null) || true

    # Return whichever is higher
    if [ -n "$release_tag" ] && [ -n "$tag_tag" ]; then
        if version_gte "$release_tag" "$tag_tag"; then
            best="$release_tag"
        else
            best="$tag_tag"
        fi
    elif [ -n "$release_tag" ]; then
        best="$release_tag"
    else
        best="$tag_tag"
    fi

    echo "$best"
}

# Get latest Go version from go.dev
go_latest_version() {
    curl -fsSL 'https://go.dev/dl/?mode=json' | python3 -c '
import sys, json
releases = json.load(sys.stdin)
for r in releases:
    if r.get("stable"):
        print(r["version"].removeprefix("go"))
        break
'
}

# Get latest aptakube version (no 'v' prefix in tags)
aptakube_latest_version() {
    gh release view --repo aptakube/aptakube --json tagName -q '.tagName' 2>/dev/null
}

# Extract GIT_URL from a package Makefile and derive owner/repo
get_gh_repo() {
    local makefile="$1"
    local url
    url=$(grep '^GIT_URL' "$makefile" | head -1 | sed 's/.*:= *//' | sed 's/.git$//')
    # Extract owner/repo from github URL
    echo "$url" | sed 's|https://github.com/||'
}

# Get current PKG_VERSION from a Makefile
get_current_version() {
    grep '^PKG_VERSION' "$1" | head -1 | sed 's/.*:= *//'
}

# Update PKG_VERSION in a Makefile
set_version() {
    local makefile="$1"
    local new_version="$2"
    sed -i "s/^PKG_VERSION.*:=.*/PKG_VERSION     := $new_version/" "$makefile"
}

updates_available=0
updated_list=""

for pkg_dir in "$PACKAGES_DIR"/*/; do
    pkg=$(basename "$pkg_dir")

    # Filter to a single package if specified
    if [ -n "$FILTER" ] && [ "$pkg" != "$FILTER" ]; then
        continue
    fi

    makefile="$pkg_dir/Makefile"
    if [ ! -f "$makefile" ]; then
        continue
    fi

    current=$(get_current_version "$makefile")

    # Get latest version based on package type
    case "$pkg" in
        golang)
            latest=$(go_latest_version)
            ;;
        aptakube)
            latest=$(aptakube_latest_version)
            ;;
        *)
            repo=$(get_gh_repo "$makefile")
            if [ -z "$repo" ]; then
                echo "$(yellow "SKIP") $pkg - no GIT_URL found"
                continue
            fi
            latest=$(gh_latest_version "$repo")
            ;;
    esac

    if [ -z "$latest" ]; then
        echo "$(yellow "SKIP") $pkg - could not determine latest version"
        continue
    fi

    if [ "$current" = "$latest" ]; then
        printf "  %-20s %s\n" "$pkg" "$(green "$current") (up to date)"
    elif version_gte "$current" "$latest"; then
        printf "  %-20s %s (local %s is ahead of upstream %s)\n" "$pkg" "$(yellow "SKIP")" "$current" "$latest"
    else
        printf "  %-20s %s -> %s\n" "$pkg" "$(yellow "$current")" "$(bold "$latest")"
        updates_available=1

        if [ "$UPDATE" = true ]; then
            set_version "$makefile" "$latest"
            printf "  %-20s %s\n" "" "$(green "updated")"
            updated_list+="$pkg $current $latest"$'\n'
        fi
    fi
done

if [ "$UPDATE" = false ] && [ "$updates_available" -eq 1 ]; then
    echo ""
    echo "Run with --update to apply changes."
fi

# Write updated list to stdout fd 3 if open (used by auto-update.sh)
if [ -n "$updated_list" ] && { true >&3; } 2>/dev/null; then
    printf '%s' "$updated_list" >&3
fi

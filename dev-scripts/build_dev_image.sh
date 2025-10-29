#!/bin/bash

# Exit early if any command fails
set -e

rm -rf temp-frontend || echo OK

# Clone custom frontend into temp-frontend (override via FRONTEND_REPO and FRONTEND_REF)
FRONTEND_REPO="${FRONTEND_REPO:-https://github.com/tbotteam/caprover-frontend.git}"
git clone "$FRONTEND_REPO" ./temp-frontend
if [ -n "$FRONTEND_REF" ]; then
    git -C ./temp-frontend checkout "$FRONTEND_REF"
fi

rm -rf ./temp-frontend/node_modules
rm -rf ./temp-frontend/.git

pwd

# Always build and push a multi-arch image using Docker Buildx.
if [ -z "$TARGET_IMAGE" ]; then
    CAPTAIN_CONSTANTS_FILE="./src/utils/CaptainConstants.ts"
    if [ -f "$CAPTAIN_CONSTANTS_FILE" ]; then
        PUBLISHED_NAME=$(sed -n "s/^[[:space:]]*publishedNameOnDockerHub:[[:space:]]*'\([^']*\)'.*/\1/p" "$CAPTAIN_CONSTANTS_FILE" | head -n1)
        VERSION_TAG=$(sed -n "s/^[[:space:]]*version:[[:space:]]*'\([^']*\)'.*/\1/p" "$CAPTAIN_CONSTANTS_FILE" | head -n1)
        if [ -n "$PUBLISHED_NAME" ] && [ -n "$VERSION_TAG" ]; then
            TARGET_IMAGE="${PUBLISHED_NAME}:${VERSION_TAG}"
            echo "Resolved TARGET_IMAGE from CaptainConstants.ts: $TARGET_IMAGE"
        fi
    fi
    if [ -z "$TARGET_IMAGE" ]; then
        echo "ERROR: TARGET_IMAGE is required, e.g. export TARGET_IMAGE=youruser/caprover:custom (or set publishedNameOnDockerHub/version in CaptainConstants.ts)" >&2
        exit 1
    fi
fi

PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
docker run --rm --privileged tonistiigi/binfmt --install all || true
docker buildx create --name caproverbuilder >/dev/null 2>&1 || true
docker buildx use caproverbuilder
docker buildx build --platform "$PLATFORMS" \
    -t "$TARGET_IMAGE" \
    -f dockerfile-captain.dev --push .
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

# If TARGET_IMAGE is set, build and PUSH a multi-arch image using buildx.
# Otherwise, do a simple local dev build (single-arch) to caprover-dev-image:0.0.1
if [ -n "$TARGET_IMAGE" ]; then
    PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
    docker run --rm --privileged tonistiigi/binfmt --install all || true
    docker buildx create --name caproverbuilder >/dev/null 2>&1 || true
    docker buildx use caproverbuilder
    docker buildx build --platform "$PLATFORMS" \
        -t "$TARGET_IMAGE" \
        -f dockerfile-captain.dev --push .
else
    docker build --no-cache -f dockerfile-captain.dev -t caprover-dev-image:0.0.2 .
fi
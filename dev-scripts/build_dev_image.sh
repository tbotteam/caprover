#!/bin/bash

# Exit early if any command fails
set -e

sudo echo OK

mkdir temp-frontend || echo OK

rm -rf temp-frontend/*

# Clone custom frontend into temp-frontend (override via FRONTEND_REPO and FRONTEND_REF)
FRONTEND_REPO="${FRONTEND_REPO:-https://github.com/tbotteam/caprover-frontend.git}"
git clone "$FRONTEND_REPO" ./temp-frontend
if [ -n "$FRONTEND_REF" ]; then
    git -C ./temp-frontend checkout "$FRONTEND_REF"
fi

rm -rf ./temp-frontend/node_modules
rm -rf ./temp-frontend/.git

pwd

sudo docker build -f dockerfile-captain.dev -t caprover-dev-image:0.0.1 .
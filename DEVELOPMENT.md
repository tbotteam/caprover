## Building and Publishing the CapRover Image (with custom frontend)

### How it works

- `dev-scripts/build_dev_image.sh` clones your frontend repo into `temp-frontend/`, then builds the Docker image.
- The script always builds and pushes a multi-arch image via Docker Buildx.
- It reads the image name and tag from `src/utils/CaptainConstants.ts` using `publishedNameOnDockerHub` and `version`.

### Change image name and version

- Edit `src/utils/CaptainConstants.ts`:
    - `configs.publishedNameOnDockerHub`: Docker Hub repo/name
    - `configs.version`: image tag
- Alternatively, override both with an environment variable: `TARGET_IMAGE=<repo/name:tag>`

### Build and push

- Ensure Docker is running and you are logged in (`docker login`).
- Default (uses values from `CaptainConstants.ts`):
    ```bash
    npm run build:dev-image
    ```
- Override target image and/or platforms:
    ```bash
    export TARGET_IMAGE=youruser/caprover:custom
    # optional: export PLATFORMS=linux/amd64,linux/arm64
    npm run build:dev-image
    ```

### macOS note

- If you see a permission error when deleting `temp-frontend/`, prefix the command with sudo:
    ```bash
    sudo npm run build:dev-image
    ```

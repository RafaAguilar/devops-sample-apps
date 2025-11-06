#!/usr/bin/env sh
UTILS_DIR="${PROJECT_ROOT:-$HOME}/.utils"
mkdir -p "$UTILS_DIR"

DGOSS_BIN="$UTILS_DIR/dgoss"
export GOSS_PATH="$UTILS_DIR/goss"

APP_VERSION=${APP_VERSION:-v0.1}
APP_PORT=${APP_PORT:-9191}

download() {
    local url="$1"
    local dest="$2"

    echo "Downloading $url → $dest ..."
    curl -L "$url" -o "$dest" || {
        echo "Failed to download $url" >&2
        exit 1
    }
    chmod +x "$dest"
    echo "$dest is ready."
}

# build the image
docker build -f go.containerfile . -t golang:$APP_VERSION

# test the image
# TODO: the below binaries represent a risk with this method of downlading them
#       we should either have a fixed version and a checksum, or we should use a trusted repository.
[[ -f "$DGOSS_BIN" ]] || download \
    "https://github.com/goss-org/goss/releases/latest/download/dgoss" \
    "$DGOSS_BIN"

[[ -f "$GOSS_PATH" ]] || download \
    "https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64" \
    "$GOSS_PATH"

echo "Both binaries are available in $UTILS_DIR"

$DGOSS_BIN run  --volume ./tmp/file.p12:/app/file.p12 golang:$APP_VERSION

# run the golang app
docker run -p 127.0.0.1:$APP_PORT:80  --volume ./tmp/file.p12:/app/file.p12 golang:$APP_VERSION

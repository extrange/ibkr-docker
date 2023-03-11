#!/bin/bash

# Prepares Dockerfile and image files for later build step

if [ $# -ne 2 ]; then
	echo "Usage: ./update-dockerfile.sh <stable|latest> <version>"
	exit 1
fi

CHANNEL=$1
VERSION=$2

if [[ "$CHANNEL" != "stable" ]] && [[ "$CHANNEL" != "latest" ]]; then
	echo "'${CHANNEL}' must be either 'stable' or 'latest'"
	exit 1
fi

OUTPUT_DIR="./$CHANNEL"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp -r image-files/ "$OUTPUT_DIR"

CHANNEL="$CHANNEL" VERSION="$VERSION" envsubst '$CHANNEL $VERSION' <"Dockerfile.template" >"$OUTPUT_DIR/Dockerfile"

#!/bin/bash

# Directory containing assets
ASSETS_DIR="assets"

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "Error: cwebp is not installed. Please install it (e.g., 'brew install webp')."
    exit 1
fi

# Find all jpg, jpeg, and png files in the assets directory
find "$ASSETS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r FILE; do
    # Determine the output filename (replace extension with .webp)
    OUT_FILE="${FILE%.*}.webp"

    # Check if the WebP file already exists
    if [ ! -f "$OUT_FILE" ]; then
        echo "Converting $FILE..."

        # Determine width to handle "at most 800 pixels wide"
        WIDTH=0
        if command -v sips &> /dev/null; then
            # macOS built-in tool
            WIDTH=$(sips -g pixelWidth "$FILE" | tail -n 1 | awk '{print $2}')
        elif command -v identify &> /dev/null; then
            # ImageMagick
            WIDTH=$(identify -format "%w" "$FILE")
        fi

        # Construct arguments: -q 80 is default, add resize if width > 800
        # -resize 800 0 maintains aspect ratio
        if [ "$WIDTH" -gt 800 ]; then
            cwebp -q 80 "$FILE" -o "$OUT_FILE" -resize 800 0
        else
            cwebp -q 80 "$FILE" -o "$OUT_FILE"
        fi
    fi
done
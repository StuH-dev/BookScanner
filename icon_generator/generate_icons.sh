#!/bin/bash

# Required sizes for iOS app icons
SIZES=(40 60 58 87 76 114 80 120 180 128 192 136 152 167 1024)

# Create output directory if it doesn't exist
mkdir -p ../BookVault/Assets.xcassets/AppIcon.appiconset

# Generate PNG files for each size
for size in "${SIZES[@]}"; do
    echo "Generating ${size}x${size} icon..."
    /opt/homebrew/bin/rsvg-convert -w $size -h $size icon.svg > "../BookVault/Assets.xcassets/AppIcon.appiconset/bookvault_${size}.png"
done

echo "Icon generation complete!"

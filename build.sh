#!/bin/sh
set -e

# Load environment variables
source ./.env

# Install requirements
pip install python-dotenv

# Create output directory structure
THEME_DIR="SplashOS-Icon-Theme"
mkdir -p "$THEME_DIR"

# Create directories for each enabled size
declare -a SIZES=()
if [ "${sit_global_render_32}" = "true" ]; then SIZES+=(32); fi
if [ "${sit_global_render_64}" = "true" ]; then SIZES+=(64); fi
if [ "${sit_global_render_128}" = "true" ]; then SIZES+=(128); fi
if [ "${sit_global_render_256}" = "true" ]; then SIZES+=(256); fi
if [ "${sit_global_render_512}" = "true" ]; then SIZES+=(512); fi

# Create index.theme file
cat > "$THEME_DIR/index.theme" << EOL
[Icon Theme]
Name=SplashOS Theme
Comment=The official icon theme for SplashOS
Inherits=MoreWaita,Adwaita
Directories=$(for s in "${SIZES[@]}"; do echo -n "applications/$s,"; done | sed 's/,$//')

$(for s in "${SIZES[@]}"; do
echo "[applications/$s]
Size=$s
Context=Applications
Type=Fixed
"
done)
EOL

# Process all blend files
find src/blend/applications -name "*.blend" | while read blend_file; do
    echo "Processing $blend_file..."
    blender -b "$blend_file" -P src/render.py -- "$THEME_DIR/applications"
done

echo "Icon theme build complete!"

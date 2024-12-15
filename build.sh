#!/bin/sh
set -e

# Load .env if needed
if [ -f ./.env ]; then
    source ./.env
fi

# Install requirements
pip install python-dotenv

# Create output directory structure
THEME_DIR="SplashOS-Icon-Theme"
mkdir -p "$THEME_DIR"

# Set default values if not specified in .env
: "${sit_global_render_32:=true}"
: "${sit_global_render_64:=true}"
: "${sit_global_render_128:=true}"
: "${sit_global_render_256:=true}"
: "${sit_global_render_512:=true}"

# Export the variables so they're available to the Python script
export sit_global_render_32
export sit_global_render_64
export sit_global_render_128
export sit_global_render_256
export sit_global_render_512

# Install requirements
pip install python-dotenv

# Create output directory structure
THEME_DIR="SplashOS-Icon-Theme"
mkdir -p "$THEME_DIR"

# Create directories for each enabled size
SIZES=()
[ "${sit_global_render_32}" = "true" ] && SIZES+=(32)
[ "${sit_global_render_64}" = "true" ] && SIZES+=(64)
[ "${sit_global_render_128}" = "true" ] && SIZES+=(128)
[ "${sit_global_render_256}" = "true" ] && SIZES+=(256)
[ "${sit_global_render_512}" = "true" ] && SIZES+=(512)


# Create directory string for index.theme
DIR_STRING=$(printf "applications/%s," "${SIZES[@]}" | sed 's/,$//')

# Create index.theme file
cat > "$THEME_DIR/index.theme" << EOL
[Icon Theme]
Name=SplashOS Theme
Comment=The official icon theme for SplashOS
Inherits=MoreWaita,Adwaita
Directories=$DIR_STRING

$(for size in "${SIZES[@]}"; do
echo "[applications/$size]
Size=$size
Context=Applications
Type=Fixed
"
done)
EOL

# Make sure the script is executable
chmod +x src/render.py

# Process all blend files
find src/blend/applications -name "*.blend" | while read blend_file; do
    echo "Processing $blend_file..."

    # Collect all sit_ environment variables and format them for passing to the script
    ENV_ARGS=""
    while IFS='=' read -r name value; do
        if [[ $name == sit_* ]]; then
            ENV_ARGS="$ENV_ARGS --env $name=$value"
        fi
    done < <(env)

    # Run blender with environment variables passed as arguments
    blender --python-use-system-env -b "$blend_file" -P src/render.py -- "$THEME_DIR/applications" $ENV_ARGS
done

echo "Icon theme build complete!"

#!/bin/sh

# Exit on error
set -e

THEME_NAME="SplashOS-Icon-Theme"
SYSTEM_THEME_DIR="/usr/share/icons"

# Get the real user's home directory even when using sudo
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$USER"
fi

REAL_HOME=$(eval echo ~$REAL_USER)
USER_THEME_DIR="$REAL_HOME/.local/share/icons"

# Function to install theme
install_theme() {
    local target_dir="$1"
    local install_type="$2"

    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"

    # Remove existing theme if present
    if [ -d "$target_dir/$THEME_NAME" ]; then
        echo "Removing existing theme installation..."
        rm -rf "$target_dir/$THEME_NAME"
    fi

    # Copy theme files
    echo "Installing theme to $target_dir/$THEME_NAME..."
    cp -r "$THEME_NAME" "$target_dir/"

    # Set correct permissions
    if [ "$install_type" = "system" ]; then
        chmod -R 755 "$target_dir/$THEME_NAME"
    else
        # For user installation, ensure the real user owns the files
        chown -R "$REAL_USER:$(id -gn $REAL_USER)" "$target_dir/$THEME_NAME"
        chmod -R 755 "$target_dir/$THEME_NAME"
    fi

    # Update icon cache
    echo "Updating icon cache..."
    if [ "$install_type" = "system" ]; then
        gtk-update-icon-cache -f -t "$target_dir/$THEME_NAME"
    else
        # Run gtk-update-icon-cache as the real user
        su - "$REAL_USER" -c "gtk-update-icon-cache -f -t '$target_dir/$THEME_NAME'"
    fi
}

# Check if theme directory exists
if [ ! -d "$THEME_NAME" ]; then
    echo "Error: Theme directory not found. Please run build.sh first."
    exit 1
fi

# Provide installation options
echo "Select installation type:"
echo "1) System-wide installation (requires root)"
echo "2) User installation"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        # Check if script is run as root for system-wide installation
        if [ "$EUID" -ne 0 ]; then
            echo "Please run with sudo for system-wide installation"
            exit 1
        fi
        install_theme "$SYSTEM_THEME_DIR" "system"
        echo "Theme installed system-wide successfully!"
        ;;
    2)
        install_theme "$USER_THEME_DIR" "user"
        echo "Theme installed for user $REAL_USER successfully!"
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        exit 1
        ;;
esac

echo "Installation complete! You can now select the theme in your system settings."

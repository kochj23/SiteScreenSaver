#!/bin/bash
# Installation script for Site ScreenSaver 2.0

echo "🚀 Site ScreenSaver 2.0 Installer"
echo "=================================="
echo ""

# Find the built screensaver
SAVER_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Site ScreenSaver 2.0.saver" -type d 2>/dev/null | head -1)

if [ -z "$SAVER_PATH" ]; then
    echo "❌ Error: Could not find built screensaver"
    echo "   Please build the project in Xcode first (⌘B)"
    exit 1
fi

echo "✅ Found screensaver at:"
echo "   $SAVER_PATH"
echo ""

# Create Screen Savers directory if it doesn't exist
INSTALL_DIR="$HOME/Library/Screen Savers"
mkdir -p "$INSTALL_DIR"

# Copy the screensaver
echo "📦 Installing screensaver..."
cp -R "$SAVER_PATH" "$INSTALL_DIR/"

if [ $? -eq 0 ]; then
    echo "✅ Successfully installed to:"
    echo "   $INSTALL_DIR/Site ScreenSaver 2.0.saver"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Open System Preferences > Screen Saver"
    echo "   2. Select 'Site ScreenSaver 2.0' from the list"
    echo "   3. Click 'Screen Saver Options...' to configure"
    echo ""
    echo "🎉 Installation complete!"

    # Optionally open System Preferences
    read -p "Open System Preferences now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "x-apple.systempreferences:com.apple.preference.desktopscreeneffect"
    fi
else
    echo "❌ Error: Installation failed"
    exit 1
fi

# Site ScreenSaver 2.0

A macOS screensaver that automatically cycles through multiple web dashboards with smooth scrolling. Perfect for displaying rotating dashboards on information displays, monitoring walls, or any always-on screens.

## Features

- 🖥️ **Multi-Monitor Support** - Each monitor displays different dashboards independently
- 🔄 **Automatic Rotation** - Cycles through multiple dashboards continuously
- 📜 **Smooth Scrolling** - Animated scroll from top to bottom of each page
- ⚙️ **Configurable Timing** - Adjust scroll speed, load delays, and post-scroll delays
- 📁 **CSV File Support** - Load dashboard URLs from CSV files
- 💾 **Persistent Storage** - URLs and settings are saved automatically
- 🎛️ **Preferences Panel** - Full configuration through System Preferences
- 🌐 **Multiple Input Methods** - Load from CSV, add URLs individually, or use remote config
- 🔒 **Secure** - HTTPS enforcement for remote configuration URLs
- 💬 **Error Handling** - Clear error messages and recovery options

## Requirements

- macOS 13.0 (Ventura) or later
- Internet connection for loading dashboards
- HTTPS-accessible configuration file (optional)

## Installation

### Method 1: Install from Build

1. Build the project in Xcode (⌘B)
2. The screensaver will be located at:
   ```
   ~/Library/Developer/Xcode/DerivedData/Site_ScreenSaver_2.0-.../Build/Products/Debug/Site ScreenSaver 2.0.saver
   ```
3. Double-click the `.saver` file to install it
4. System Preferences will open automatically
5. Select "Site ScreenSaver 2.0" from the list

### Method 2: Manual Installation

1. Build the project in Xcode
2. Copy the `.saver` bundle to:
   ```
   ~/Library/Screen Savers/
   ```
   or
   ```
   /Library/Screen Savers/  (for all users)
   ```
3. Open System Preferences > Screen Saver
4. Select "Site ScreenSaver 2.0" from the list

## Configuration

### Opening Preferences

1. Open **System Preferences** > **Screen Saver**
2. Select **"Site ScreenSaver 2.0"** from the list
3. Click the **"Screen Saver Options..."** button

### Adding Dashboard URLs

#### Method 1: Add Individual URLs

1. Click **"Add URL..."**
2. Enter the complete URL (including `http://` or `https://`)
3. Click **"Add"**
4. Repeat to add more URLs

#### Method 2: Load from CSV File

1. Click **"Load CSV..."**
2. Select a CSV or TXT file containing URLs (one per line)
3. URLs are imported automatically

**CSV File Format:**
```csv
https://dashboard1.example.com
https://dashboard2.example.com
https://metrics.company.com/realtime
# Comments are supported
"https://url-with-special-characters.com/path?param=value"
https://status.example.com
```

**CSV File Rules:**
- ✅ One URL per line
- ✅ URLs can be quoted with double or single quotes
- ✅ Lines starting with `#` are treated as comments
- ✅ Empty lines are ignored
- ✅ URLs must include `http://` or `https://`
- ❌ Invalid URLs are skipped with a warning

#### Method 3: Load from Remote Configuration

1. Click **"Load Remote..."**
2. Enter an HTTPS URL pointing to a remote configuration file
3. Click **"Load"**
4. URLs are fetched and saved automatically

**Security Note:** Remote configuration URLs must use HTTPS for security.

### Managing URLs

- **View URLs**: All configured URLs are displayed in the preferences table
- **Remove URL**: Select a URL in the table and click **"Remove"**
- **Clear All**: Click **"Clear All"** to remove all URLs (with confirmation)

### Timing Settings

Click **"Timing Settings..."** to adjust:

- **Scroll Duration** (5-30 seconds, default: 10s)
  - How long the smooth scroll animation takes

- **Page Load Delay** (0.5-10 seconds, default: 2s)
  - Wait time after loading a page before starting scroll
  - Allows page content to fully render

- **Post-Scroll Delay** (1-60 seconds, default: 20s)
  - Wait time at the bottom of the page before moving to next dashboard
  - Gives time to view the full content

All settings are automatically saved and persist across reboots.

## How It Works

### Rotation Cycle

For each dashboard in the configuration:

1. **Load** (0.5-10 seconds, default 2s) - Page is loaded and rendered
2. **Scroll** (5-30 seconds, default 10s) - Smooth animated scroll from top to bottom
3. **Dwell** (1-60 seconds, default 20s) - View the bottom of the page
4. **Next** - Move to the next dashboard and repeat

### Multi-Monitor Behavior

When multiple monitors are connected:
- Each monitor displays a **different dashboard** from your rotation list
- Dashboards cycle **independently** on each screen
- Each monitor starts at a different offset in the rotation
- This provides maximum information density across all displays

Example with 3 monitors and 6 dashboards:
- Monitor 1: Shows dashboards 1, 4, 1, 4, ...
- Monitor 2: Shows dashboards 2, 5, 2, 5, ...
- Monitor 3: Shows dashboards 3, 6, 3, 6, ...

## Development

### Project Structure

```
Site ScreenSaver 2.0/
├── Site ScreenSaver 2.0/
│   ├── SiteScreenSaverView.h         # Main screensaver view header
│   ├── SiteScreenSaverView.m         # Main screensaver implementation
│   ├── SiteScreenSaverConfigController.h  # Preferences window header
│   ├── SiteScreenSaverConfigController.m  # Preferences window implementation
│   └── Info.plist                    # Bundle metadata
└── Site ScreenSaver 2.0.xcodeproj    # Xcode project
```

### Key Components

**SiteScreenSaverView.m**
- Dashboard rotation logic
- WKWebView integration
- Smooth scroll implementation
- Multi-monitor support
- Settings management

**SiteScreenSaverConfigController.m**
- Preferences window UI
- URL management (Add/Remove/CSV/Remote)
- Timing settings dialog
- Persistent storage via ScreenSaverDefaults

### Building from Source

```bash
cd "/Users/kochj/Desktop/xcode/Site ScreenSaver 2.0"
xcodebuild -project "Site ScreenSaver 2.0.xcodeproj" \
           -scheme "Site ScreenSaver 2.0" \
           -destination 'platform=macOS' \
           build
```

### Testing

1. Build the project
2. Double-click the resulting `.saver` file to install
3. Open System Preferences > Screen Saver
4. Select "Site ScreenSaver 2.0"
5. Click "Test" to preview

Or use the command line:
```bash
/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -module "Site ScreenSaver 2.0"
```

## Customization

### Timing Constants

Edit the constants in `SiteScreenSaverView.m`:

```objective-c
static const NSTimeInterval kMinPageLoadDelay = 0.5;
static const NSTimeInterval kMaxPageLoadDelay = 10.0;
static const NSTimeInterval kDefaultPageLoadDelay = 2.0;
static const NSTimeInterval kMinPostScrollDelay = 1.0;
static const NSTimeInterval kMaxPostScrollDelay = 60.0;
static const NSTimeInterval kDefaultPostScrollDelay = 20.0;
static const double kMinScrollDuration = 5.0;
static const double kMaxScrollDuration = 30.0;
static const double kDefaultScrollDuration = 10.0;
```

### Scroll Animation

The scroll uses an easing function for smooth motion. To change the easing, edit the JavaScript in the `scrollCurrentDashboard` method:

```javascript
function easeInOutQuad(t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}
```

Available easing functions:
- Linear: `return t;`
- Ease In: `return t * t;`
- Ease Out: `return t * (2 - t);`
- Ease In Out (current): `return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;`

## Troubleshooting

### Screensaver Not Loading

**Problem:** "Site ScreenSaver 2.0" doesn't appear in System Preferences

**Solutions:**
- Verify the `.saver` file is in `~/Library/Screen Savers/`
- Restart System Preferences
- Check Console.app for error messages
- Ensure macOS version is 13.0 or later

### Configuration Not Saving

**Problem:** URLs or settings are lost after restart

**Solutions:**
- Check that you're clicking "OK" in the preferences window
- Verify ScreenSaverDefaults are being saved (check Console.app logs)
- Try resetting preferences:
  ```bash
  defaults delete com.digitalnoise.SiteScreenSaver2
  ```

### Remote Config Not Loading

**Problem:** "Network error" or "HTTP XXX: Failed to load config"

**Solutions:**
- Verify the configuration URL is accessible in a web browser
- Ensure the URL uses HTTPS (not HTTP)
- Check your internet connection
- Verify the server is online and responding

### Dashboards Not Scrolling

**Problem:** Dashboard loads but doesn't scroll

**Solutions:**
- Page may not be tall enough to scroll
- Check Console.app for "Page is not scrollable" message
- Some pages prevent scrolling via JavaScript
- Try a different dashboard
- Verify the page content loads fully

### Multi-Monitor Issues

**Problem:** All monitors show the same dashboard

**Solutions:**
- This shouldn't happen with the current implementation
- Check Console.app logs for monitor index calculations
- Try disconnecting and reconnecting monitors
- Restart the screensaver

## Console Logging

The screensaver provides detailed logging with emoji indicators:

- ✅ Success messages (green checkmark)
- ❌ Error messages (red X)
- ⚠️ Warning messages (yellow warning)
- 🌐 Network operations
- 📄 Page loading
- 📜 Scrolling operations
- ▶️ Start/stop actions
- 💾 Settings saved

View logs in **Console.app** by filtering for "SiteScreenSaver".

## Best Practices

### Dashboard Design

For best results:

- ✅ Design dashboards with vertical scrolling in mind
- ✅ Use responsive designs that work at various resolutions
- ✅ Ensure content is readable from a distance
- ✅ Use high contrast colors
- ✅ Avoid time-sensitive content that expires quickly
- ❌ Avoid dashboards requiring user interaction
- ❌ Avoid pages with auto-refresh that might interfere

### Configuration Management

- Keep your CSV configuration file under version control
- Use comments in CSV to document what each dashboard shows
- Test URLs before adding them to rotation
- Group related dashboards together
- Remove dashboards that are temporarily unavailable

### Display Setup

- Use dedicated displays or monitors
- Disable screen sleep in System Preferences
- Consider the physical distance viewers will be from screens
- Set appropriate display resolution for dashboard designs
- Test the rotation on all connected monitors

## Security Considerations

- Configuration URLs must use HTTPS to prevent tampering
- Dashboard URLs are validated before loading
- The screensaver enforces URL scheme validation
- No authentication credentials are stored or transmitted
- Network requests use standard URLSession security
- Uses ScreenSaverDefaults for secure preference storage

## Performance

The screensaver is optimized for:

- **Low memory usage** - Uses weak/strong references to prevent leaks
- **Efficient rendering** - WebKit handles page rendering
- **Smooth animations** - RequestAnimationFrame for 60fps scrolling
- **Network efficiency** - Cancels duplicate configuration requests
- **Multi-monitor efficiency** - Each monitor runs independently

## Limitations

- Dashboards must be web-based (no native apps)
- Requires internet connectivity
- Remote configuration file must be HTTPS-accessible
- Scroll speed limited to 5-30 seconds
- No authentication for private dashboards (use VPN if needed)
- WebView may not support all modern web features
- Some websites may block embedding in WebViews

## Comparison with Site Rotator 2.0

| Feature | Site Rotator 2.0 (App) | Site ScreenSaver 2.0 |
|---------|------------------------|----------------------|
| Platform | Standalone macOS app | macOS screensaver |
| Multi-monitor | Single window | Independent per monitor |
| Configuration | In-app menus | System Preferences panel |
| Launch | Manual app launch | Automatic on idle |
| Settings storage | UserDefaults | ScreenSaverDefaults |
| User interface | Full app with menus | Screensaver only |
| Window management | User-controlled | System-controlled |
| Activation | Click "Start" button | System idle timeout |

## Support

For issues, suggestions, or contributions:

1. Check the console logs in Console.app for detailed error messages
2. Review the Troubleshooting section above
3. Verify your configuration file is correctly formatted
4. Test individual dashboard URLs in a web browser

## License

Copyright © 2024. All rights reserved.

## Changelog

### Version 2.0 (Current)

- ✨ Complete screensaver implementation
- ✨ Multi-monitor support with independent content
- ✨ CSV File Support - Load dashboard URLs from CSV files
- ✨ Persistent Storage - URLs automatically saved via ScreenSaverDefaults
- ✨ Full preferences panel - Add, view, and manage URLs
- ✨ Configurable Timing - Adjust all timing parameters
- ✨ Multiple Input Methods - CSV files, manual URL entry, or remote configuration
- ✨ Smooth scroll animation with easing
- ✨ HTTPS enforcement for remote configs
- ✨ Comprehensive logging with emoji indicators
- ✨ Error handling with clear messages
- 📝 Complete documentation
- 🔧 Built with Xcode 15.0+
- 🎯 Targets macOS 13.0+

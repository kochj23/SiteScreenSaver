# Quick Start Guide
## Site ScreenSaver 2.0

**Status:** ✅ Installed and Ready

---

## Installation Complete!

The screensaver is now installed at:
```
~/Library/Screen Savers/Site ScreenSaver 2.0.saver
```

System Preferences should have opened automatically. If not, follow these steps:

---

## Step 1: Select the Screensaver

1. Open **System Preferences** (if not already open)
2. Click **Desktop & Screen Saver** (or **Screen Saver** on newer macOS)
3. Look for **"Site ScreenSaver 2.0"** in the list on the left
4. Click on it to select it

**Note:** If you don't see it, try:
- Closing and reopening System Preferences
- Or run: `open "$HOME/Library/Screen Savers/Site ScreenSaver 2.0.saver"`

---

## Step 2: Configure Your Dashboards

1. Click the **"Screen Saver Options..."** button (bottom right)
2. A preferences window will open showing your configuration options

### Test URLs Already Configured ✅

I've pre-configured three test URLs for you:
- https://www.apple.com
- https://www.google.com
- https://github.com

These will appear in the URL table in the preferences window.

---

## Step 3: Add Your Own Dashboards

You have three ways to add dashboards:

### Method A: Add Individual URLs
1. Click **"Add URL..."**
2. Enter the complete URL (e.g., `https://example.com/dashboard`)
3. Click **"Add"**
4. Repeat for more URLs

### Method B: Import from CSV File
1. Create a CSV file with one URL per line:
   ```
   https://dashboard1.example.com
   https://dashboard2.example.com
   https://metrics.company.com
   ```
2. Click **"Load CSV..."**
3. Select your CSV file
4. URLs are imported automatically

### Method C: Load from Remote URL
1. Click **"Load Remote..."**
2. Enter an HTTPS URL pointing to your config file
   - Example: `https://example.com/dashboards.txt`
3. Click **"Load"**
4. URLs are fetched and saved

**Security Note:** Remote URLs must use HTTPS!

---

## Step 4: Adjust Timing (Optional)

Click **"Timing Settings..."** to customize:

- **Scroll Duration** (5-30s, default: 10s)
  - How long it takes to scroll through each page

- **Page Load Delay** (0.5-10s, default: 2s)
  - Wait time for page to load before scrolling

- **Post-Scroll Delay** (1-60s, default: 20s)
  - Time to view the bottom before moving to next dashboard

---

## Step 5: Test It Out

1. Click **"OK"** in the preferences window to save
2. Back in System Preferences, click **"Test"** button
3. The screensaver will start immediately in full-screen

**To exit test:** Move your mouse or press any key

---

## Step 6: Set Activation Time

1. In System Preferences, set **"Start after:"** to your preferred idle time
2. Common settings: 5, 10, or 20 minutes

---

## Multi-Monitor Setup

If you have multiple monitors:

- ✅ Each monitor will show **different dashboards** automatically
- ✅ They cycle **independently** from each other
- ✅ Maximum information density across all screens

**Example with 3 monitors and 6 dashboards:**
- Monitor 1: Shows dashboards 1, 4, 1, 4, ...
- Monitor 2: Shows dashboards 2, 5, 2, 5, ...
- Monitor 3: Shows dashboards 3, 6, 3, 6, ...

---

## Managing Your URLs

### View All URLs
All configured URLs appear in the table in the preferences window.

### Remove a URL
1. Click on a URL in the table to select it
2. Click **"Remove"** button
3. URL is deleted immediately

### Clear Everything
1. Click **"Clear All"** button
2. Confirm the action
3. All URLs are removed

---

## Tips for Best Results

### Dashboard Design
- ✅ Use dashboards designed for vertical scrolling
- ✅ Ensure good contrast for readability from distance
- ✅ Test URLs in a browser first
- ❌ Avoid dashboards requiring user login (unless using VPN)
- ❌ Avoid sites that block embedding

### URL Management
- Keep 3-10 dashboards for good rotation variety
- Group related dashboards together
- Use descriptive comments in CSV files (`# Production metrics`)
- Test each URL before adding to rotation

### Performance
- Avoid too many dashboards (>20) as it increases memory usage
- Use lightweight dashboard pages when possible
- Ensure stable internet connection

---

## Troubleshooting

### Screensaver Not Appearing
**Problem:** Don't see "Site ScreenSaver 2.0" in list

**Solution:**
```bash
# Reinstall
cd "/Users/kochj/Desktop/xcode/Site ScreenSaver 2.0"
./install.sh

# Then restart System Preferences
```

### Preferences Button Doesn't Work
**Problem:** Clicking "Screen Saver Options..." does nothing

**Solution:** This is rare but try:
1. Quit System Preferences
2. Reopen it
3. Select the screensaver again

### URLs Not Saving
**Problem:** Configuration lost after closing preferences

**Solution:**
- Make sure you click **"OK"** not just close the window
- Check Console.app for error messages
- Try clearing preferences: `defaults delete com.digitalnoise.SiteScreenSaver2`

### Dashboards Not Loading
**Problem:** Screensaver shows blank screen

**Solution:**
- Check internet connection
- Verify URLs work in Safari
- Check Console logs: `log stream --predicate 'process == "legacyScreenSaver"'`
- Ensure URLs don't block embedding

---

## Console Logs

View real-time logs to debug issues:

```bash
# Watch screensaver logs
log stream --predicate 'process == "legacyScreenSaver"' --level debug
```

Look for these indicators:
- ✅ `Success` - Operations completed
- ❌ `Error` - Problems occurred
- 🌐 `Fetching` - Loading content
- 📄 `Loading dashboard` - Page being loaded
- 📜 `Scrolling` - Scroll animation running

---

## Quick Commands

### Reinstall
```bash
cd "/Users/kochj/Desktop/xcode/Site ScreenSaver 2.0"
./install.sh
```

### Uninstall
```bash
rm -rf ~/Library/Screen\ Savers/Site\ ScreenSaver\ 2.0.saver
```

### Reset All Settings
```bash
defaults delete com.digitalnoise.SiteScreenSaver2
```

### Test Immediately
```bash
/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine \
  -module "Site ScreenSaver 2.0"
```

---

## Example CSV File

Create a file named `dashboards.csv`:

```csv
# Production Dashboards
https://grafana.company.com/dashboard1
https://grafana.company.com/dashboard2

# Monitoring
https://status.company.com/live
https://metrics.company.com/realtime

# Analytics
https://analytics.company.com/overview
"https://analytics.company.com/details?view=full"
```

Then load it via **"Load CSV..."** in preferences.

---

## Support

For issues:
1. Check this guide first
2. Review the README.md for detailed documentation
3. Check Console.app for error logs
4. Verify your CSV/remote config file format

---

## You're All Set! 🎉

Your Site ScreenSaver 2.0 is installed and configured with test URLs.

**Next Steps:**
1. ✅ System Preferences is open (or open it now)
2. ✅ Select "Site ScreenSaver 2.0" from the list
3. ✅ Click "Screen Saver Options..." to see the configuration
4. ✅ Add your own dashboard URLs
5. ✅ Click "Test" to see it in action!

Enjoy your automated dashboard rotation! 🚀

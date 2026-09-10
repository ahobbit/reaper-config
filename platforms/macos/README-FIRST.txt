MACOS: APPLE SILICON & INTEL (REAPER NATIVE MODE)

1. Copy and extract this folder. Close REAPER if it is open.
2. Run `Apply-configuration.command`.
   - It checks your current REAPER installation. If missing or older than 7.79,
     it downloads the official build from reaper.fm and validates its SHA-256 hash.
   - If an existing newer version is present, it is kept as-is.
   - New installs go into ~/Applications/REAPER.app; updates create a backup of
     the previous application bundle before upgrading.
   - It creates an automatic backup of your existing configuration, then adapts
     and applies the new settings for your user account.
   - If Finder prevents running the script, open Terminal and execute:
     bash /path/to/Apply-configuration.command
   - SWS and ReaPack extensions are installed automatically into UserPlugins.
   - Do NOT run REAPER under Rosetta with ARM-native plugins.
3. Open REAPER. Configure your Audio and MIDI devices in Preferences.
   - On the Reapertips Colors toolbar, click:
     Color management > Load color set from file
   - Load: ~/Library/Application Support/REAPER/ColorSets/Reapertips/Mac-Reapertips.SWSColor
   - macOS stores these in the system color picker; loading from file avoids
     overwriting personal colors used in other Mac apps.

Review COMPATIBILITY.md for details. Third-party plugins, libraries, and licenses are not included.
If an older or mismatched ReaPack/SWS architecture exists in UserPlugins, remove it to prevent conflicts.
The backup folder path will be printed in Terminal. To restore previous settings: close REAPER,
rename the current REAPER resource folder, and copy the backup folder back into place.
User fonts are not removed upon restoring previous settings.

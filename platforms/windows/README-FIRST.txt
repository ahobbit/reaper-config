REAPER + REAPERTIPS FOR WINDOWS x64
Prepared on September 10, 2026

HOW TO USE ON ANOTHER PC

1. Copy and extract the entire folder. Close REAPER if running.

2. Run `02-APPLY-CONFIGURATION.cmd` with your normal user account.
   - Checks for an existing REAPER install: if missing or older than 7.79,
     it downloads the official installer and verifies its SHA-256 hash.
   - Complete the normal standard x64 installation; do NOT launch REAPER when finished.
   - If you already have a newer version installed, it is kept.
   - Creates a backup of your previous REAPER configuration, then adapts and
     applies the new preferences to your user profile.
   - Ensure the process finishes with a green confirmation message.
   - If SWS is not yet installed, the script launches the SWS installer automatically.
   - The REAPER installer may ask for administrator elevation; all other steps
     run strictly inside your user profile.

3. Open REAPER.
   - Go to Preferences > Audio > Device and select your audio interface and driver.
   - Review MIDI devices in Preferences > Audio > MIDI Devices.
   - You should see the Reapertips theme and the Reapertips Colors toolbar.
   - If the toolbar is not visible: Actions > Show action list > search for
     "Toolbar: Open/close toolbar 2" and run it.
   - Under Extensions in the main menu, verify that SWS/S&M and ReaPack appear.

WHAT IS CONFIGURED

- Reapertips 1.93b theme and all 5 color variants.
- Fira Sans Regular/Bold and Roboto Bold fonts, installed for your user.
- Custom icons, color toolbar, and actions.
- 12 Windows color palettes + Starter; Reapertips colors enabled automatically.
- Automatic backups every minute when not recording (up to 50 per project).
- Projects, Auto Backups, Unsaved Projects, and Peaks directories in Documents\REAPER.
- Mouse-centered zoom; normal/hidden folders; 24px track spacers.
- Meters and recording previews refreshed at ~30 Hz.
- Unified MIDI editor layout, appearance, and recording naming syntax.
- Media buffer 600 ms / 50%; render block size 1024 samples.
- ReaPack 1.2.6 configured with standard community repositories.
- SWS 2.14.0.7 via official included installer.

CHANGES WHEN MOVING FROM MAC TO WINDOWS

Paths are adapted automatically. The macOS CoreAudio driver, Mac MIDI ports,
CPU thread counts, and specific multi-monitor window coordinates are excluded.
Windows color palettes and DLL versions of extensions are used instead of macOS dylibs.
Native window appearance may vary between operating systems. Audio latency and
buffer settings depend on your interface hardware.

Third-party plugins, VSTs, sample libraries, and licenses are not included.
Install Kontakt and other plugins using their Windows installers.
Audio Units (AU) are macOS-only: use VST3 or CLAP equivalents on Windows.
Projects, recordings, and peak cache files are excluded.
REAPER requires your own license key or evaluation period; no registration info
is transferred.

CHANGING COLOR PALETTES

Click "Color management" on the toolbar > "Load color set from file".
Palettes are located in the resource folder: ColorSets\Reapertips.
To update toolbar icons to match a specific palette, close REAPER and copy the PNGs
from `Reapertips Palettes\Toolbar\Toolbar Icons\<NAME>` over `Data\toolbar_icons`.
Open REAPER and load the corresponding `Win-<NAME>.SWSColor`.

BACKUPS & RESTORATION

Before overwriting any settings, the script creates a backup copy of your existing
REAPER configuration in:
`Documents\REAPER\Configuration Backups\Before-Reapertips-<DATE>\REAPER`
To roll back: close REAPER, rename current `%APPDATA%\REAPER`, and copy the backed-up
folder back to `%APPDATA%`.
Fonts are installed into your user profile and are preserved across restorations.

MANUAL RESTORE (if scripts cannot be run)

1. Install REAPER 7.79+ from https://www.reaper.fm/download.php.
2. With REAPER closed, make a backup copy of `%APPDATA%\REAPER`.
3. Copy the contents of `Configuration` into `%APPDATA%\REAPER`.
4. In `reaper.ini` and `S&M.ini`, replace `@@RESOURCE@@` with the full path to
   `%APPDATA%\REAPER` and `@@DOCUMENTS@@` with your Documents path (use forward slashes `/`).
   Do NOT run REAPER with unreplaced placeholders.
5. Copy `Installers\reaper_reapack-x64.dll` into `UserPlugins\`.
6. Install the fonts from `Fonts\` using the Windows Install button.
7. Run the SWS installer.
8. In REAPER, click Color management > Load color set from file and select
   `ColorSets\Reapertips\Win-Reapertips.SWSColor`.

PACKAGE CONTENTS

- Configuration: REAPER resources pre-configured for Windows.
- Installers: SWS and ReaPack x64; REAPER downloaded on demand (or bundled with --offline).
- Fonts: Theme typography fonts.
- COMPATIBILITY.md: System matrix and verification notes.
- SHA256.json: Integrity manifest checked by the installer before copying.

Official installer sources:
https://www.reaper.fm/download.php
https://sws-extension.org/
https://github.com/cfillion/reapack/releases/tag/v1.2.6

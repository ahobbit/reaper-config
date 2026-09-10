# Compatibility Matrix — September 10, 2026

Pinned versions: REAPER 7.79, Reapertips Theme 1.93b, SWS 2.14.0.7, ReaPack 1.2.6, ReaperDarkMode 1.1.0.

| Component | Shared | Platform Differences / Notes |
|---|---|---|
| Theme & Images | Yes | Requires REAPER 7; native OS menus and fonts may vary slightly. |
| TTF Fonts | Yes | User-level installation procedure differs per OS. |
| Editing Preferences, MIDI, Backups & Meters | Equivalent base | Per-platform `reaper.ini`; personalized paths are adapted during install. |
| Toolbars & Color Actions | Yes | Actions require the SWS extension to be installed. |
| Color Palettes | No (separate Mac/Win files) | Different native byte order; Windows stores `custcolors` in REAPER config; Mac uses system color picker and requires loading palette once. |
| Mouse / Shortcuts | Retained current files | Check Cmd/Ctrl/Option and input hardware; gesture equivalence is not guaranteed across systems. |
| REAPER | Separate installer | Windows x64 and macOS Universal (Intel / Apple Silicon). Windows ARM64EC is not covered. |
| SWS | Separate binary | Available for Windows x64, Mac Intel, and Mac ARM64. Install while REAPER is closed. |
| ReaPack | Separate binary | Windows x64 DLL, macOS Intel/ARM64 dylib; shared repository list configuration. |
| Dark Mode | Windows & Mac | Windows uses bundled ReaperDarkMode 1.1.0 (Windows 10/11 x64); macOS uses native Mojave+ dark mode (`mac_dark_mode=1`). |
| Audio & MIDI Devices | No | Choose target machine's interface and drivers. CoreAudio does not transfer to Windows. |
| Third-Party Plugins & VSTs | Not included | Reinstall appropriate version and licenses. AU has no Windows equivalent; VST3/CLAP require per-platform binaries. |
| Window Positions & Scaling | Approximate | Mac screen coordinates are not copied; adjust to your display resolution. |
| Projects, Media, Licenses & Peak Caches | Not included | This repository tracks configuration only, not a complete DAW studio snapshot. |

On Apple Silicon, REAPER is expected to run natively in ARM64 mode (not via Rosetta). Avoid having duplicate copies of SWS/ReaPack for different architectures in `UserPlugins`. Package bundles are designed for standard user profile installations, not portable installs.

## What Has Been Verified

Original settings, theme, SWS, ReaPack, and custom toolbars were tested on REAPER 7.79 on an Apple Silicon Mac. Newly generated packages are validated by SHA-256 hashes, icon/action references, absence of hardcoded personal paths, and shell syntax tests. The 16-color Mac/Windows byte order conversion has been cross-checked.

The PowerShell installer on Windows and clean/Intel Mac restoration have been syntactically and structurally verified, but not live-tested on bare machines. The generator script does not alter the active working REAPER installation. Audio buffer presets reflect recommended tutorial baselines, not hardware-tailored benchmarks.

## Primary References

- [REAPER: Download & Platforms](https://www.reaper.fm/download.php)
- [SWS Extension: Versions & Architectures](https://sws-extension.org/)
- [ReaPack 1.2.6: Platform Binaries](https://github.com/cfillion/reapack/releases/tag/v1.2.6)
- [SWS: Color Persistence & Conversion](https://github.com/reaper-oss/sws/blob/master/Color/Color.cpp)
- [Microsoft: WritePrivateProfileStruct](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-writeprivateprofilestructa)
- [Reapertips Theme: Requirements](https://www.reapertips.com/products/reapertips-theme)
- [ReaperDarkMode: RobKor77](https://github.com/RobKor77/ReaperDarkMode)
- [Reapertips: REAPER Dark Mode on Windows](https://www.reapertips.com/post/reaper-dark-mode-on-windows)

## On-Demand Downloads

- **Windows:** Automatically detects standard paths and App Paths registry entries, compares executable version, runs official interactive installer, and re-checks version afterwards.
- **macOS:** Automatically detects installations in `~/Applications` and `/Applications`, inspects `Info.plist`, downloads Universal DMG, and safely copies the bundle with backup. Prompts for manual install if permissions are insufficient.
- Only updates towards the repository's pinned version; never downgrades an existing newer version.

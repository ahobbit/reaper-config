# Changelog

## v1.0.0 — 2026-09-10

Initial traceable release after installing Reapertips 1.93b, applying the balanced configuration from "The Perfect Setup", and adding color palettes/toolbar.

- Automatic backups: saves every minute when not recording, up to 50 backups per project; separate folders for projects, peaks, and unsaved work.
- Mouse-centered zoom, normal/hidden folders, 24px track spacers, customized item appearance options.
- Meter refresh at 30 Hz and 40 dB/s decay; recording preview at ~30 Hz.
- Unified MIDI editor with linked selection; recording naming pattern `$track-$recpass00`.
- Media buffer 600 ms / 50%, render block size 1024 samples.
- Preserved user recording safeguards, default crossfades, timebase, and custom shortcuts.
- Platform profiles with parameterized paths; external binaries locked by SHA-256.
- Hardware-specific settings excluded (audio/MIDI devices, CPU thread count, display window coordinates).
- Floating toolbar 2 enabled for Reapertips Colors; default palette preconfigured.
- Verified packaging manifests and scripts. On-demand official REAPER installer download with hash verification and offline bundling options.

## v1.0.1 — 2026-09-10

Separated Kontakt 8 Audio Unit preset metadata into macOS platform profile (contains colons in filename, invalid on Windows filesystems). Added Windows filename validation to distribution build checks.

## v1.0.2 — 2026-09-10

- Automated SWS extension installation: macOS script mounts SWS DMG and copies dylib directly; Windows script auto-launches SWS installer if missing.
- Added `-ExecutionPolicy Bypass` to Windows launcher to prevent script execution restrictions.
- Migrated packaging pipeline to automated GitHub Actions with calendar-dated releases (`REAPER Setup YYYY-MM-DD`).
- Standardized all script names, directory structures, and console messages to English.
- Simplified documentation with user-centric quick start guides.

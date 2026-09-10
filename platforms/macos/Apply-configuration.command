#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if pgrep -x REAPER >/dev/null || pgrep -x reaper >/dev/null; then
  echo 'Please close REAPER before applying the configuration.'; exit 1
fi
shasum -a 256 -c SHA256SUMS >/dev/null
bash ./Prepare-REAPER.sh
resource="$HOME/Library/Application Support/REAPER"
backup="$HOME/Documents/REAPER/Configuration Backups/Before-Reapertips-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$resource" "$HOME/Library/Fonts"
if [ -f "$resource/reaper.ini" ]; then ditto "$resource" "$backup/REAPER"; fi
if [ -d "$HOME/Library/Fonts" ]; then
  mkdir -p "$backup/Fonts"
  for f in Fonts/*.ttf; do
    if [ -f "$HOME/Library/Fonts/$(basename "$f")" ]; then cp "$HOME/Library/Fonts/$(basename "$f")" "$backup/Fonts/"; fi
  done
fi
# First prepare personalized files without touching the running installation.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
ditto Configuration "$stage/Configuration"
export REAPERTIPS_RESOURCE="$resource"
export REAPERTIPS_DOCUMENTS="$HOME/Documents"
while IFS= read -r -d '' f; do
  /usr/bin/perl -pi -e 's/\@\@RESOURCE\@\@/$ENV{REAPERTIPS_RESOURCE}/g; s/\@\@DOCUMENTS\@\@/$ENV{REAPERTIPS_DOCUMENTS}/g' "$f"
done < <(find "$stage/Configuration" \( -name '*.ini' -o -name '*.RPP' \) -print0)
ditto "$stage/Configuration" "$resource"
for folder in Projects Peaks 'Auto Backups' 'Unsaved Projects'; do mkdir -p "$HOME/Documents/REAPER/$folder"; done
cp Fonts/*.ttf "$HOME/Library/Fonts/"
mkdir -p "$resource/UserPlugins"
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = 1 ]; then
  cp Installers/reaper_reapack-arm64.dylib "$resource/UserPlugins/"
  sws_dmg="Installers/SWS-2.14.0.7-macOS-AppleSilicon.dmg"
  sws_dylib="reaper_sws-arm64.dylib"
else
  cp Installers/reaper_reapack-x86_64.dylib "$resource/UserPlugins/"
  sws_dmg="Installers/SWS-2.14.0.7-macOS-Intel.dmg"
  sws_dylib="reaper_sws-x86_64.dylib"
fi
if [ -f "$sws_dmg" ]; then
  sws_mount=$(mktemp -d)
  if yes 2>/dev/null | hdiutil attach -nobrowse -readonly -mountpoint "$sws_mount" "$sws_dmg" >/dev/null 2>&1; then
    if [ -f "$sws_mount/$sws_dylib" ]; then
      cp "$sws_mount/$sws_dylib" "$resource/UserPlugins/"
    fi
    if [ -d "$sws_mount/Grooves" ]; then
      mkdir -p "$resource/Grooves"
      ditto "$sws_mount/Grooves" "$resource/Grooves/"
    fi
    hdiutil detach "$sws_mount" >/dev/null 2>&1 || true
  fi
  rmdir "$sws_mount" 2>/dev/null || true
fi
printf '\nConfiguration applied. Backup: %s\n' "$backup"
printf 'ReaPack and SWS extensions installed. Launch REAPER in native mode.\n'
printf 'In the Colors toolbar: Color management > Load color set from file > ColorSets/Reapertips/Mac-Reapertips.SWSColor.\n'
printf 'Select your audio and MIDI devices in Preferences.\n'

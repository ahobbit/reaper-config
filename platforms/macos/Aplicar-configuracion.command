#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if pgrep -x REAPER >/dev/null || pgrep -x reaper >/dev/null; then
  echo 'Cierra REAPER antes de aplicar la configuracion.'; exit 1
fi
shasum -a 256 -c SHA256SUMS >/dev/null
bash ./Preparar-REAPER.sh
resource="$HOME/Library/Application Support/REAPER"
backup="$HOME/Documents/REAPER/Configuration Backups/Antes-Reapertips-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$resource" "$HOME/Library/Fonts"
if [ -f "$resource/reaper.ini" ]; then ditto "$resource" "$backup/REAPER"; fi
if [ -d "$HOME/Library/Fonts" ]; then
  mkdir -p "$backup/Fonts"
  for f in Fuentes/*.ttf; do
    if [ -f "$HOME/Library/Fonts/$(basename "$f")" ]; then cp "$HOME/Library/Fonts/$(basename "$f")" "$backup/Fonts/"; fi
  done
fi
# First prepare personalized files without touching the running installation.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
ditto Configuracion "$stage/Configuracion"
export REAPERTIPS_RESOURCE="$resource"
export REAPERTIPS_DOCUMENTS="$HOME/Documents"
while IFS= read -r -d '' f; do
  /usr/bin/perl -pi -e 's/\@\@RESOURCE\@\@/$ENV{REAPERTIPS_RESOURCE}/g; s/\@\@DOCUMENTS\@\@/$ENV{REAPERTIPS_DOCUMENTS}/g' "$f"
done < <(find "$stage/Configuracion" -name '*.ini' -print0)
ditto "$stage/Configuracion" "$resource"
for folder in Projects Peaks 'Auto Backups' 'Unsaved Projects'; do mkdir -p "$HOME/Documents/REAPER/$folder"; done
cp Fuentes/*.ttf "$HOME/Library/Fonts/"
mkdir -p "$resource/UserPlugins"
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = 1 ]; then
  cp Instaladores/reaper_reapack-arm64.dylib "$resource/UserPlugins/"
else
  cp Instaladores/reaper_reapack-x86_64.dylib "$resource/UserPlugins/"
fi
printf '\nConfiguracion aplicada. Backup: %s\n' "$backup"
printf 'Instala SWS para tu arquitectura. Abre REAPER en modo nativo.\n'
printf 'En la barra Colors: Color management > Load color set from file > ColorSets/Reapertips/Mac-Reapertips.SWSColor.\n'
printf 'Selecciona tu dispositivo de audio y MIDI.\n'

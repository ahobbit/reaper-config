#!/bin/bash
# Called from the package directory after manifest verification.
set -euo pipefail
required='7.79'
app=''
for candidate in "$HOME/Applications/REAPER.app" '/Applications/REAPER.app'; do
  if [ -d "$candidate" ]; then app="$candidate"; break; fi
done
version_at_least() {
  awk -v actual="$1" -v required="$2" 'BEGIN {split(actual,a,".");split(required,b,".");for(i=1;i<=3;i++){if(a[i]+0>b[i]+0)exit 0;if(a[i]+0<b[i]+0)exit 1}exit 0}'
}
if [ -n "$app" ]; then
  installed=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
  if version_at_least "${installed%%_*}" "$required"; then echo "REAPER compatible ya instalado: $app ($installed)"; exit 0; fi
fi
installer='Instaladores/REAPER-7.79-macOS-Universal.dmg'
url='https://www.reaper.fm/files/7.x/reaper779_universal.dmg'
expected=$(cat REAPER-macos.sha256)
if [ ! -f "$installer" ]; then
  mkdir -p Instaladores
  curl --fail --location --proto '=https' --tlsv1.2 "$url" -o "$installer.partial"
  actual=$(shasum -a 256 "$installer.partial" | awk '{print $1}')
  [ "$actual" = "$expected" ] || { echo 'Hash del instalador incorrecto.'; exit 1; }
  mv "$installer.partial" "$installer"
fi
actual=$(shasum -a 256 "$installer" | awk '{print $1}')
[ "$actual" = "$expected" ] || { echo 'Hash del instalador incorrecto.'; exit 1; }
mountdir=$(mktemp -d)
mounted=0
cleanup() { if [ "$mounted" = 1 ]; then hdiutil detach "$mountdir" >/dev/null || true; fi; rmdir "$mountdir" 2>/dev/null || true; }
trap cleanup EXIT
hdiutil attach -nobrowse -readonly -mountpoint "$mountdir" "$installer" >/dev/null
mounted=1
[ -d "$mountdir/REAPER.app" ] || { echo 'No se encuentra REAPER.app dentro del instalador oficial.'; exit 1; }
if [ -z "$app" ]; then mkdir -p "$HOME/Applications"; app="$HOME/Applications/REAPER.app"; fi
parent=$(dirname "$app")
if [ ! -w "$parent" ]; then
  echo "No hay permisos de escritura en $parent. Instala el DMG manualmente y vuelve a ejecutar el script."
  exit 1
fi
if [ -d "$app" ]; then
  backup="$HOME/Documents/REAPER/Configuration Backups/App-$(date +%Y%m%d-%H%M%S)-$$"
  mkdir -p "$backup"
  mv "$app" "$backup/REAPER.app"
  if ! ditto "$mountdir/REAPER.app" "$app"; then
    echo "La copia fallo. La aplicacion anterior esta en $backup/REAPER.app."
    exit 1
  fi
else
  ditto "$mountdir/REAPER.app" "$app"
fi
installed=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
version_at_least "${installed%%_*}" "$required" || { echo 'Version instalada inesperada.'; exit 1; }
echo "REAPER instalado: $app ($installed)"

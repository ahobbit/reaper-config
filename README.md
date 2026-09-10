# Mi configuración REAPER / Reapertips

Configuración personal reproducible para **Windows x64** y **macOS Intel/Apple Silicon**. Repositorio local creado a partir de los ajustes aplicados el 9–10 de septiembre de 2026. No tiene remoto y no se ha publicado.

## Qué guarda Git

- `common/`: barras, acciones, ratón, repositorios ReaPack, scripts/efectos y recursos compartidos.
- `platforms/windows/`: preferencias adaptables, paletas Windows e instalador PowerShell.
- `platforms/macos/`: preferencias Mac, paletas Mac y restauración `.command`.
- `fonts/`: fuentes del tema.
- `dependencies.lock.json`: versiones, URL oficial y SHA-256 de cada instalador/extensión.
- `docs/`: compatibilidad e historial de decisiones.
- `scripts/build.py`: crea carpetas/ZIP para trasladar a otro equipo.

Se mantienen los seis temas Reapertips y sus iconos en Git para poder restaurar el aspecto exacto. Los temas de fábrica se obtienen del instalador REAPER. Instaladores, ZIP generados, grabaciones, cachés y licencias se excluyen con `.gitignore`. Los recursos de terceros conservan su autoría; este es un repositorio de uso personal, sin licencia de redistribución añadida.

## Instalar

Usa los paquetes de `dist/` y sigue su `LEEME-PRIMERO.txt`. Los scripts hacen copia de seguridad, adaptan rutas a tu usuario y conservan los ajustes de esta configuración. Selecciona audio y MIDI en el equipo destino. Instala los plugins externos por separado.

[Consulta las compatibilidades y límites de verificación](docs/COMPATIBILIDAD.md).

## Generar paquetes desde Git

Requiere Python 3.9+ únicamente en el equipo que genera el paquete. Los usuarios de los paquetes no necesitan Python.

```sh
python3 scripts/build.py all --download
# Para incluir tambien REAPER y no necesitar descargarlo en destino:
python3 scripts/build.py all --download --offline
```

Si `dist/REAPER-Reapertips-windows` o `dist/REAPER-Reapertips-macos` ya existen, muévelos a otro lugar antes de regenerar. El generador se niega a sobrescribir entregas anteriores. `--offline` incluye REAPER; sin esa opción el script del destino lo descarga solo si falta o es antiguo. `--download` descarga solo los archivos ausentes y comprueba sus hashes; no instala ni ejecuta software.

## Mantener el historial

Después de cambiar REAPER, cierra la aplicación para que guarde sus preferencias. Compara el ajuste correspondiente con los archivos versionados y traslada solo el cambio deseado. No copies indiscriminadamente la carpeta de recursos: incluye rutas locales, dispositivos, cachés y estado de ventanas.

```sh
git diff
git add common platforms docs dependencies.lock.json
git commit -m "Describe el ajuste y por qué cambió"
```

Actualiza `docs/CHANGELOG.md` con el motivo y la verificación. Para recursos binarios, cambia el archivo y anota la versión. Para instaladores, actualiza URL y hash en el lock. Los cambios futuros de la aplicación **no se sincronizan automáticamente** con Git.

Para inspeccionar una versión anterior sin modificar tu REAPER: `git show v1.0.0:platforms/windows/reaper.ini`. Restaurar Git no restaura automáticamente la aplicación: genera/aplica el paquete deseado con REAPER cerrado.

## Publicación

No se ha creado repositorio remoto. Para guardar el historial fuera del ordenador se puede añadir posteriormente un remoto privado. El Git local y el paquete de recuperación son cosas distintas: conserva ambos.

## Comprobación automática de REAPER

El script comprueba la instalación normal del sistema. Descarga **la versión fijada en el lock**, no una versión nueva arbitraria: eso mantiene repetible el entorno. Comprueba SHA-256 antes de usar el instalador. Conserva cualquier versión instalada igual o superior. Windows abre el instalador interactivo oficial; Mac monta el DMG oficial y copia la aplicación si tiene permisos. No suprime los avisos de seguridad del sistema ni acepta automáticamente acuerdos del instalador Windows.

Para adoptar otra versión se actualizan URL, hash y versión del lock; el helper Mac y su hash deben actualizarse conjuntamente (el validador detecta inconsistencias). Las instalaciones portables y rutas Windows no estándar requieren instalación manual.

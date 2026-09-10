# Compatibilidad comprobada — 10 de septiembre de 2026

Versiones fijadas: REAPER 7.79, Reapertips Theme 1.93b, SWS 2.14.0.7, ReaPack 1.2.6.

| Componente | Compartido | Diferencia o comprobación pendiente |
|---|---|---|
| Tema e imágenes | Sí | Requiere REAPER 7; menús nativos y tipografía pueden variar. |
| Fuentes TTF | Sí | Instalación de usuario distinta en cada sistema. |
| Preferencias de edición, MIDI, backups y medidores | Base equivalente | `reaper.ini` por plataforma; rutas personalizadas durante instalación. |
| Barras y acciones de color | Sí | Las acciones requieren SWS instalado. |
| Paletas | No, archivos Mac/Win separados | Orden nativo de bytes distinto; Windows guarda `custcolors` en REAPER; Mac usa selector del sistema y requiere cargar paleta una vez. |
| Ratón/teclas | Se conservan los archivos actuales | Revisar Cmd/Ctrl/Option y el hardware de entrada; no garantizar equivalencia de cada gesto. |
| REAPER | Instalador separado | Windows x64 y macOS Universal Intel/ARM. Windows ARM64EC no está cubierto. |
| SWS | Binario separado | Windows x64, Mac Intel y Mac ARM64 disponibles. Instalar con REAPER cerrado. |
| ReaPack | Binario separado | DLL Windows x64, dylib macOS Intel/ARM64; configuración de repositorios común. |
| Audio y MIDI | No | Elegir controlador y puertos del ordenador destino. CoreAudio no se transporta a Windows. |
| Instrumentos y efectos externos | No incluidos | Reinstalar versión compatible y licencia. AU no tiene versión Windows; VST3/CLAP requieren binarios de cada plataforma. |
| Ventanas y escalado | Aproximado | No se copian posiciones de la pantalla del Mac; ajustar al monitor destino. |
| Modo oscuro macOS | Solo Mac | Se conserva el ajuste observado; depende del aspecto del sistema. |
| Proyectos, medios, licencias y cachés | No incluidos | Este repositorio versiona la configuración, no una copia del estudio completo. |

En Apple Silicon se espera REAPER nativo ARM64, no ejecutado con Rosetta. Evitar dos copias de SWS/ReaPack de arquitecturas distintas en UserPlugins. Los paquetes son para instalaciones normales con recursos en el perfil del usuario, no instalaciones portables.

## Qué está verificado

Los ajustes originales, el tema, SWS, ReaPack y la barra se verificaron en REAPER 7.79 del Mac Apple Silicon durante la configuración. Los paquetes nuevos se comprueban por hashes, referencias de iconos/acciones, ausencia de rutas personales en configuración y sintaxis shell. La conversión de las 16 entradas de color Mac/Windows se ha cotejado.

No se ha ejecutado el instalador PowerShell en Windows ni la restauración completa en un Mac limpio/Intel. El generador no modifica el REAPER de trabajo. Los ajustes de buffer son presets del tutorial, no mejoras demostradas mediante benchmarks.

## Fuentes primarias

- [REAPER: plataformas y descargas](https://www.reaper.fm/download.php)
- [SWS: versiones y arquitecturas](https://sws-extension.org/)
- [ReaPack 1.2.6: archivos por plataforma](https://github.com/cfillion/reapack/releases/tag/v1.2.6)
- [SWS: persistencia y conversión de colores](https://github.com/reaper-oss/sws/blob/master/Color/Color.cpp)
- [Microsoft: WritePrivateProfileStruct](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-writeprivateprofilestructa)
- [Reapertips Theme: requisitos](https://www.reapertips.com/products/reapertips-theme)

## Descarga bajo demanda

Windows: detección de rutas estándar y App Paths, comparación de versión del ejecutable, instalador oficial interactivo y nueva comprobación tras instalar. Mac: detección en ~/Applications y /Applications, comparación de Info.plist, descarga del Universal y copia con respaldo de la aplicación anterior. Si falta permiso de escritura, se detiene y pide instalación manual. Solo se actualiza hacia la versión fijada en el repositorio; nunca se rebaja una versión superior. La política se ha revisado, pero los caminos de instalación real no se ejecutaron sobre las aplicaciones del usuario.

# Historial

## v1.0.0 — 2026-09-10

Primera versión trazable tras instalar Reapertips 1.93b, aplicar la selección equilibrada de The Perfect Setup y añadir las paletas/barra de colores.

- Preferencias de backups: cada minuto cuando no se graba, hasta 50 por proyecto; rutas de proyectos, picos y recuperación separadas.
- Zoom al ratón, carpetas normal/oculto, espaciadores 24 px, opciones visuales de ítems.
- Medidores 30 Hz y 40 dB/s; previsualizaciones de grabación ~30 Hz.
- Editor MIDI compartido y selección enlazada; nombres `$track-$recpass00`.
- Buffer de medios 600 ms / 50 %, render de 1024 muestras.
- Se mantienen salvaguardas de grabación, fades, timebase y shortcuts del usuario.
- Perfiles de plataforma con rutas parametrizadas; binarios externos fijados por hash.
- Se excluyen dispositivos audio/MIDI, hilos CPU y posiciones de ventanas del Mac origen.
- Barra de color 2 visible; paleta Reapertips por defecto. Mac requiere importación manual de colores en SWS.
- Sin remoto Git. Validación estructural de paquetes; pendiente prueba de restauración en Windows y Mac limpio.

- Instalación/actualización de REAPER bajo demanda desde URL oficial, con hash fijado y conservación de versiones superiores. Opción offline del generador.

## v1.0.1 — 2026-09-10

Separa el estado del preset Audio Unit de Kontakt en el perfil Mac: su nombre contiene dos puntos y no puede copiarse a Windows. Añade validación de nombres de archivo Windows a los paquetes generados.

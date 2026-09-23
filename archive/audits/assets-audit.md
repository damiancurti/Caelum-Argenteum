# Auditoría de assets/

Fecha: 2026-09-23. Alcance: todos los archivos bajo `assets/`, clasificados por
referencia cruzada contra `src/`, `docs/`, `README.md`, `AGENTS.md`, `.github/`
y los generadores de `assets/generators/`. Auditoría de solo lectura: no se
modificó, movió ni borró ningún archivo.

Total auditado: **419 archivos**, **131,09 MB**.

## Resumen por categoría

| Categoría | Archivos | Espacio aproximado (MB) |
| --- | ---: | ---: |
| RUNTIME | 0 | 0,00 |
| SOURCE | 387 | 128,68 |
| RESERVE | 12 | 1,07 |
| HISTORICAL | 0 | 0,00 |
| ORPHAN | 20 | 1,33 |
| UNCLEAR | 0 | 0,00 |

Notas sobre el método:

- **RUNTIME** se interpretó como "un archivo de `assets/` referenciado desde
  `src/` (ZScript, MODELDEF, TEXTURES, SNDINFO, MAPINFO, LANGUAGE o mapas UDMF)
  como recurso de ejecución". No hay ninguno: las 8 menciones a `assets/`
  dentro de `src/` están en comentarios o en `src/licenses/` y apuntan a la
  *procedencia* de recursos ya generados en `src/`, no a un consumo en runtime.
- **SOURCE** agrupa (a) las entradas que los generadores leen para regenerar
  algo que entra al PK3 y (b) los paquetes de origen/procedencia que
  `docs/ASSETS.md` y `README.md` documentan como fuentes que no entran al PK3.
- Los paquetes de origen se documentan a nivel de carpeta en `ASSETS.md` (p. ej.
  `assets/first_person_v1`, `assets/source/art/poses_v3`), no archivo por
  archivo. Por eso la clasificación de SOURCE se asigna a nivel de paquete.

## Archivos ORPHAN

No aparecen referenciados por nombre ni por carpeta en `docs/ASSETS.md`,
`docs/HISTORY.md`, `README.md`, `AGENTS.md`, `.github/` ni en los generadores.

### `assets/source/art/domingo_fp_*` (16 archivos, ~1,32 MB)

Orígenes de primera persona de Domingo de las versiones 4.32.0h/0i/0j/0n. La
auditoría 4.33.0h trasladó los originales a `assets/source/art/`, pero los
documentos actuales no los mencionan individualmente ni como carpeta.

- `source/art/domingo_fp_4_32_0h/DSHDI0_2x_720x480.png`
- `source/art/domingo_fp_4_32_0h/LHNDI0_2x_720x480.png`
- `source/art/domingo_fp_4_32_0h/RHNDA0_2x_960x480.png`
- `source/art/domingo_fp_4_32_0i/DSHDI0_2x_900x600.png`
- `source/art/domingo_fp_4_32_0i/LHNDI0_2x_900x600.png`
- `source/art/domingo_fp_4_32_0i/IMAGEGEN_PROMPTS.txt`
- `source/art/domingo_fp_4_32_0j/DSWDH0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0j/DSWDI0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0j/IMAGEGEN_PROMPTS.txt`
- `source/art/domingo_fp_4_32_0j/RFNGH0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0j/RFNGI0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0j/RHNDH0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0j/RHNDI0_FLIPPED.png`
- `source/art/domingo_fp_4_32_0n/IMAGEGEN_PROMPTS.txt`
- `source/art/domingo_fp_4_32_0n/RFNGA0_THUMB_MASTER_2x_640x400.png`
- `source/art/domingo_fp_4_32_0n/RFNGB0_THUMB_MASTER_2x_640x400.png`

### `assets/first_person_v3/` (4 archivos, ~0,01 MB)

Paquete de procedencia de las correcciones de primera persona de 4.36.0e. Su
propio `README.md` lo describe como "Native source of truth" con `SPRITES.json`,
pero ni `ASSETS.md` ni `HISTORY.md` lo mencionan (a diferencia de v1, v2, v4,
v5, v6 y v7). El resultado integrado vive en `src/graphics/caelum/first_person/v3/`.

- `first_person_v3/README.md`
- `first_person_v3/PROMPTS.json`
- `first_person_v3/PROVENANCE.json`
- `first_person_v3/SPRITES.json`

## Archivos UNCLEAR

Ninguno. Los 20 archivos sin referencia documental se clasificaron como ORPHAN
porque su contenido interno (README/PROVENANCE/PROMPTS) permite identificar su
origen con seguridad; no quedaron casos dudosos que requieran el estado UNCLEAR.

## Discrepancias entre disco y docs/ASSETS.md

### En disco pero no mencionados en ASSETS.md

Los 20 archivos ORPHAN listados arriba. El resto de `assets/` está cubierto por
las menciones a nivel de carpeta de `ASSETS.md` o `README.md`.

### Mencionados en ASSETS.md pero en una ubicación distinta a la indicada

La tabla "Reserva externa del paquete 05" de `ASSETS.md` lista 10 archivos con
rutas relativas a `src` (p. ej. `sounds/stock/music/ca_stock_piano_short_loop_01.ogg`)
como si estuvieran en `src/`. En disco no están en `src/`, sino en
`assets/audio_stock/pack05/sounds/` (la reserva externa, fuera del PK3). No es
un archivo perdido, sino una ambigüedad de ruta en la documentación:

- `sounds/creatures/ca_stock_monster_scream_01.ogg` → `assets/audio_stock/pack05/sounds/creatures/`
- `sounds/horror/ca_stock_breath_stinger_01.ogg` → `assets/audio_stock/pack05/sounds/horror/`
- `sounds/music/ca_stock_creepy_piano_stinger_01.ogg` → `assets/audio_stock/pack05/sounds/music/`
- `sounds/music/ca_stock_dark_chords_01.ogg` → `assets/audio_stock/pack05/sounds/music/`
- `sounds/music/ca_stock_piano_loop_02.ogg` → `assets/audio_stock/pack05/sounds/music/`
- `sounds/music/ca_stock_piano_short_loop_01.ogg` → `assets/audio_stock/pack05/sounds/music/`
- `sounds/props/ca_stock_toilet_flush_01.ogg` → `assets/audio_stock/pack05/sounds/props/`
- `sounds/reactions/ca_stock_slow_clap_01.ogg` → `assets/audio_stock/pack05/sounds/reactions/`
- `sounds/ui/ca_stock_triumph_jingle_01.ogg` → `assets/audio_stock/pack05/sounds/ui/`
- `sounds/voices_en/ca_stock_demonic_you_died_en.ogg` → `assets/audio_stock/pack05/sounds/voices_en/`

### Mencionados en ASSETS.md y ausentes en disco

Ninguno: todas las rutas `assets/...` citadas de forma explícita en `ASSETS.md`
existen en disco.

## Recomendación (sin ejecutarla)

- **RUNTIME (0 archivos):** nada que hacer. El runtime ya vive íntegro en `src/`.
- **SOURCE (387):** conservar como origen/procedencia. No empaquetar en el PK3.
  Documentar `assets/first_person_v3/` en `ASSETS.md` para cerrar el hueco.
- **RESERVE (12):** conservar en `assets/audio_stock/pack05/` hasta asignar un
  evento. Corregir en `ASSETS.md` la ruta de la tabla de reserva (hoy dice
  `sounds/...` relativas a `src` cuando en realidad están en `assets/`).
- **HISTORICAL (0):** nada que hacer.
- **ORPHAN (20):** no borrar sin decisión del autor. Decidir entre (a)
  documentarlos en `ASSETS.md` como procedencia histórica, o (b) moverlos a un
  respaldo (`archive/`) si el autor confirma que no son necesarios. Su volumen
  es pequeño (~1,33 MB).
- **UNCLEAR (0):** nada que hacer.


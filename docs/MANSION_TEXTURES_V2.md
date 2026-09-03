# Texturas de mansión v2 — integración 4.30.0i

## Resultado integrado

El paquete entregado por el autor contiene 58 PNG canónicos. Se adoptó como
reemplazo completo del conjunto anterior: no se mezclan sus recortes con los
85 archivos de la versión previa. La ruta original indicada por el paquete se
adaptó a la ruta ya establecida por Caelum Argenteum:

```text
src/graphics/caelum/textures/mansion/
```

`TEXTURES` registra las 58 imágenes conservando sus tamaños, nombres, canal
alfa y escala de mundo de un píxel por MU.

| Familia | Cantidad | Uso |
|---|---:|---|
| `CMEX` | 5 | Paredes exteriores |
| `CMST` | 5 | Pisos de piedra |
| `CMIN` | 5 | Paredes interiores |
| `CMWD` | 5 | Pisos de madera |
| `CMGR` | 3 | Terreno |
| `CMSP` | 5 | Frentes de escalón |
| `CMDR` | 5 | Puertas con alfa |
| `CMGT` | 2 | Portones con alfa |
| `CMRL` | 4 | Rejas y barandas con alfa |
| `CMCR` | 3 | Alfombras |
| `CMPW` | 2 | Muros de piscina y fuente |
| `CMBS` | 5 | Establo y granero |
| `CMTB` | 4 | Terraza, balcón y techo |
| `CMDT` | 5 | Detalles y decoraciones |

El inventario, manifiesto y listado de migración originales del paquete quedan
preservados en `tools/assets/mansion_v2/`. Las copias integradas de los 58 PNG
son byte-idénticas a los archivos entregados; sus hashes se verificaron contra
el archivo `CHECKSUMS_SHA256.txt` de la entrega antes del empaquetado.

## Compatibilidad de MAP01

MAP01 todavía utiliza cuatro identificadores históricos que el conjunto v2
retira. Se mantienen sólo como composiciones basadas en recursos v2; ningún
PNG obsoleto se conserva:

| Nombre histórico | Recurso v2 |
|---|---|
| `CMGR01A` / `CMGR01B` / `CMGR01C` | `CMGR01` / `CMGR02` / `CMGR03` |
| `CMRF01` | `CMTB04` |
| `CMWV01` | `CMST01` |
| `CMCL01` | Zona neutra recortada de `CMIN03` |

El ayudante `tools/migrate_4_30_0f_mansion_textures.py` comprueba que estén
presentes los 58 PNG y mueve los 48 nombres retirados a
`build/mansion_pre_4_30_0f_backup/`. El movimiento es recuperable y los
archivos adicionales desconocidos no se eliminan.

## Rejas de los balcones

La textura lógica `CMRLBAL` deriva de `CMRL02`. Se recorta únicamente su margen
alfa y se superponen tres instancias separadas por un píxel dentro de
`TEXTURES`; esto refuerza los barrotes finos para el filtrado a distancia sin
alterar el PNG canónico. El módulo final mide 32×48 MU.

| Nivel transitable | Linedefs | Longitud cubierta |
|---:|---:|---:|
| Primer piso, z=136 | 42 | 7.460 MU |
| Segundo piso, z=264 | 76 | 6.228 MU |

La corrección 4.30.0g retira por completo el contorno provisional exterior de
4.30.0f y encaja las 23 posiciones/ángulos suministrados por el autor en las
linedefs interiores que forman el borde real de cada balcón. Se conservan
expresamente la abertura central occidental y el acceso de la escalera
oriental del segundo piso. No cambia la geometría transitable ni las
cantidades de vértices, linedefs, sidedefs, sectores o Things.

La corrección 4.30.0h conserva exactamente ese trazado y corrige únicamente el
anclaje vertical. `CMRLBAL` tiene `YScale 2.583333`; sin panning mundial,
GZDoom divide `offsety_mid` por esa escala. Los offsets ahora se escriben en
unidades de textura equivalentes a la distancia mundial deseada: las bases
resultantes quedan en z=136 y z=264, verificadas en los 118 tramos y sus 236
sidedefs.

La corrección 4.30.0i aplica tres observaciones de recorrido sin crear
geometría. Retira cuatro linedefs de reja: la abertura sur de 96 MU del primer
piso y los tres segmentos que atravesaban el descanso oriental. Añade nueve:
tres para completar `x=-569, y=-92..92` y seis para proteger
`x=1689, y=-320..-64`. El trazado final contiene 123 linedefs y 246 sidedefs
de reja: 41/7.364 MU en z=136 y 82/6.476 MU en z=264.

## Aplicación de 4.30.0i

1. Extraer el ZIP 4.30.0i sobre la raíz de un proyecto 4.30.0h.
2. Aceptar el reemplazo de `src/maps/MAP01.wad` y
   `build/caelum_argenteum_dev.pk3`.
3. Ejecutar `run_dev.bat` normalmente.

El parche incluye el PK3 ya construido. Los ayudantes Python quedan como
herramientas de desarrollo reproducibles, pero el autor no necesita
ejecutarlos para instalar ni probar esta corrección.

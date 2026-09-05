# Caelum Argenteum visual assets — V4.31

## CAPOOL01

- Ruta: `graphics/caelum/textures/mansion/CAPOOL01.png`
- Uso: superficie líquida de la piscina posterior de MAP01.
- Tamaño runtime: 256×256 RGB PNG.
- Procedencia: imagen nueva generada con la herramienta de imágenes de OpenAI,
  usando la paleta acuática y el lenguaje visual del `CMPW01.png` suministrado
  por el autor como referencia.
- Transformación: reducción a 128×128 y composición especular 2×2 para producir
  un mosaico final de 256×256 cuyas cuatro aristas repiten.
- Restricciones visuales solicitadas: vista cenital, agua solamente, sin piedra,
  objetos, texto, bordes ni marcas de agua.

`CMPW01.png` permanece sin cambios.

## Prototipo de alijo 3D 4.31.0b

- Rutas: `models/caelum/props/stash/ca_stash_*.obj` y
  `models/caelum/props/stash/ca_stash_*.png`.
- Uso: estados cerrado, abierto y bloqueado del primer alijo físico.
- Procedencia: mallas y texturas originales generadas específicamente para el
  proyecto mediante `tools/generate_stash_models.py`.
- Complejidad: 242/254/266 caras para cerrado/abierto/bloqueado.
- Materiales: madera oscura, hierro, interior y candado; cuatro PNG generados
  sin recursos de Doom, bibliotecas de modelos ni texturas de terceros.
- Reproducción: el generador usa únicamente la biblioteca estándar de Python;
  sus resultados ya están incluidos y no es necesario ejecutarlo para jugar.

V4.31.0b no incorpora ningún modelo 3D descargado de terceros. Las bibliotecas
CC0 evaluadas siguen documentadas en
`docs/V4_31_WORLD_RESOURCES_AND_STASHES.md` para selección posterior.

## Rocas y vegetación regional 3D 4.31.0c

- Rutas runtime: `models/caelum/world/environment/*.obj`, sus PNG de material
  y los anclajes transparentes `sprites/CARK*.png`/`sprites/CAVT*.png`.
- Fuente conservada fuera del runtime:
  `assets/source/world/ca_environment_atlas_master.png`.
- Uso: cinco formaciones rocosas y tres variantes de vegetación para cada uno
  de los climas desierto, selva, tundra, montaña, llanura, costa y ciudad.
- Procedencia del atlas: imagen nueva generada con la herramienta de imágenes
  de OpenAI para el proyecto. Resumen del pedido visual: atlas cuadrado sin
  texto ni marcas, con cinco superficies de roca, siete cortezas y siete
  follajes de inspiración argentina, acabado semirrealista low-poly de fantasía
  oscura y color difuso plano.
- Transformación: recorte manual de 19 regiones útiles del atlas, mosaico
  especular para bordes repetibles, normalización a 256×256 y variantes
  procedurales de cactus, flores y follaje mediante Pillow.
- Mallas: geometría original determinista generada por
  `tools/generate_environment_models.py`; 26 OBJ y 14.932 caras totales.
- SHA-256 del atlas maestro:
  `943e347bcacc8d6845864bfa5e20b8078335f09fb56f9c916b5093bf316df309`.

No se descargaron ni incorporaron modelos o texturas de terceros. Los OBJ,
materiales y anclajes finales ya se distribuyen con el parche; Pillow sólo es
necesario si un desarrollador decide regenerarlos desde el atlas maestro.

## Variantes ambientales 4.31.0d

- Las 21 mallas vegetales de 4.31.0c conservan su actor de tamaño base y suman
  variantes propias al 75% y 125%, con cambios deterministas leves en ramas,
  inclinación o copa.
- Las cinco formas rocosas conservan su material y suman dos mallas geométricas
  alternativas. `MODELDEF` combina las tres formas con escalas nominales 0.5×,
  1×, 2×, 5× y 20×.
- El repertorio final contiene 78 OBJ originales, 138 actores y 44.976 caras.
- Se corrigen las ramas colgantes desconectadas del sauce y la prolongación
  superior visible del tronco en ciprés, guindo y pehuén.
- El atlas maestro y todos los PNG de material permanecen byte-idénticos a
  4.31.0c; no se añade ningún recurso de terceros.

La regeneración sigue siendo determinista mediante
`tools/generate_environment_models.py`. Los OBJ resultantes ya están incluidos
y no es necesario disponer de Python para instalar ni jugar el parche.

## Árboles adultos y física ambiental 4.31.0e

- Se añaden 48 actores `Adult`, `Adult2` y `Adult3` para las dieciséis especies
  cuyo ejemplar maduro requiere una escala mayor.
- Los nuevos actores reutilizan, sin alterarlos, los OBJ y materiales aprobados
  en 4.31.0d. No se incorpora ninguna imagen, malla ni recurso de terceros.
- Cardón, churqui, chañar, espinillo y ceibo mantienen únicamente sus tres
  variantes existentes porque ya poseen una escala acorde.
- Las masas físicas se calculan a partir del cilindro de colisión y una densidad
  nominal; este dato no modifica las mallas ni las texturas.

Los 78 OBJ y todos los PNG ambientales permanecen byte-idénticos a 4.31.0d.

## Vetas minerales originales 4.31.0f

- Rutas: `models/caelum/world/resources/ca_vein_*.obj` y `.png`, con anclajes
  transparentes `sprites/CAVE*.png`.
- Uso: hierro, carbón mineral, cobre, estaño, plata, oro, ópalo, topacio,
  zafiro, rubí y esmeralda; tres afloramientos por recurso.
- Procedencia: las 33 mallas y once materiales se generan de forma original y
  determinista mediante `tools/generate_mineral_veins.py`. La roca anfitriona
  reutiliza el material de granito original ya documentado en 4.31.0c.
- Complejidad: 25.500 vértices declarados y 7.584 caras en total. Los metales
  usan inclusiones/bandas y las gemas, cristales aflorantes de seis lados.
- Licencias externas: ninguna. No se incorpora geometría, textura ni recurso
  de Doom o de una biblioteca de terceros.

Los 78 OBJ ambientales previos y sus PNG permanecen byte-idénticos a
4.31.0e. Los nombres Adult/Young reutilizan esas mismas mallas por MODELDEF.

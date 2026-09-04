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

# Registro artístico — Domingo FP V4.32.0i

## Recurso final

- Modo: edición con la herramienta integrada de generación de imágenes.
- Casos de uso: `precise-object-edit` y `background-extraction`.
- Entrada: cuadro de Block de V4.32.0h.
- Maestro integrado del escudo:
  `art_source/domingo_fp_4_32_0i/DSHDI0_2x_900x600.png`.
- Maestro registrado de la mano:
  `art_source/domingo_fp_4_32_0i/LHNDI0_2x_900x600.png`.
- Prompts completos:
  `art_source/domingo_fp_4_32_0i/IMAGEGEN_PROMPTS.txt`.
- Exportaciones de motor: `src/sprites/DSHDI0.png` y
  `src/sprites/LHNDI0.png`.

La edición reconstruye solamente el reverso del escudo con vista ortogonal:
aro circular, grosor simétrico, tablones verticales y ausencia de inclinación o
escorzo. Se mantienen madera oscura, aro de hierro, placas de latón, remaches,
umbo central, correa ancha y empuñadura vertical. No se generaron manos, armas,
fondos ni elementos de juego adicionales.

## Alfa e integración deterministas

La herramienta dibujó el damero en RGB incluso después de la pasada explícita
de `background-extraction`. Para no introducirlo en el juego, el recorte final
se obtuvo con una máscara reproducible: semilla de luminancia al 45 %, cierre
`Disk:2`, relleno del interior cerrado, borde alfa de 0,7 píxeles y
`CopyOpacity`. Todo RGB bajo alfa cero se normalizó a negro.

El escudo aislado se redujo con Lanczos y se integró en un maestro RGBA
900×600. Su forma se ensanchó sólo en el archivo fuente para compensar el pixel
aspect 1,2 de Doom. La exportación 450×300 usa `grAb (225,48)` y muestra una
caja alfa exacta de 293×244: al renderizarse, ambos ejes producen el mismo
diámetro aparente.

La mano I se escaló desde su maestro anterior, sin regenerarla, hasta una caja
alfa 213×169 y se volvió a registrar sobre la nueva empuñadura. Escudo y mano
equivalen al 125 % del tamaño visible de V4.32.0h con el redondeo inevitable de
píxeles.

## Transformaciones de motor

- Block sostenido: capas 10/20 en X=160, Y=100.
- Reposo del conjunto derecho: Y=-18.
- Rotación absoluta de espada: 18° en reposo, 24° en preparación, 43° en
  extensión/impacto y 31° en recuperación.
- Pivote de hoja sin cambios: `(0.55625, 0.83)`.
- Manga panorámica `RHNDA0/RHNDB0`: byte por byte igual a V4.32.0h.

Estas transformaciones son exclusivamente visuales. No cambian ataque, daño,
Aire, Block, durabilidad, equipo ni persistencia.

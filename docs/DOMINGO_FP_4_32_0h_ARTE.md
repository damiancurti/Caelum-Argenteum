# Registro artístico — Domingo FP V4.32.0h

## Recurso final

- Modo: edición con la herramienta integrada de generación de imágenes.
- Caso de uso: `precise-object-edit` seguido de `background-extraction`.
- Maestro integrado (960×480):
  `art_source/domingo_fp_4_32_0h/RHNDA0_2x_960x480.png`.
- Exportaciones de motor: `src/sprites/RHNDA0.png` y
  `src/sprites/RHNDB0.png`.

La generación se utilizó únicamente para prolongar el brazal y la manga. En la
posproducción se volvió a superponer el maestro original sobre la región de
puño, agarre, tela y antebrazo ya existente; la prolongación se registró hacia
el borde derecho, se normalizó a RGBA real y se redujo una sola vez con
Lanczos. B deriva de A mediante un desplazamiento registrado de un píxel.

## Prompt de prolongación

```text
Use case: precise-object-edit
Asset type: modular first-person right-arm sprite layer for the game Caelum Argenteum
Input images: Image 1 is the exact edit target. Its left/original portion contains Domingo's right clenched hand, red cuff and armored forearm; the transparent extension area is on the right.
Primary request: extend only the existing armored forearm and sleeve naturally through the transparent area toward and beyond the right edge, as a continuous arm entering from off-screen. Preserve the original fist, grip pose, anatomy, lighting, palette, worn leather, steel bracer, brass rivets and deep-red cloth exactly.
Composition/framing: keep the existing hand and forearm at precisely the same position, size and angle. Continue the arm along its existing lower-right direction until it exits the far-right canvas edge; there must be no visible straight cutoff before that edge.
Style/medium: the exact existing semi-realistic dark-fantasy hand-painted game-sprite style.
Constraints: change only the missing right-side continuation; retain true transparent RGBA everywhere else; one right arm only; no weapon, no sword, no shield, no left hand, no body, no background, no shadow, no text, no border, no watermark.
Avoid: moving or redesigning the fist; changing the grip; opaque or black background; checkerboard; glow; duplicated armor; extra objects.
```

## Prompt final de transparencia

```text
Use case: background-extraction
Asset type: modular first-person right-arm sprite layer for Caelum Argenteum
Input images: Image 1 is the generated extended arm and is the exact edit target.
Primary request: remove the entire gray-and-white checkerboard background and replace it with genuine transparent alpha.
Constraints: preserve every arm pixel, silhouette, position, scale, lighting, materials and colors exactly; change only the background transparency; keep the armored forearm extending cleanly through the right canvas edge; no halo, no checkerboard pixels, no opaque background, no shadow, no extra object, no text, no watermark.
```

## Transformaciones deterministas adicionales

- El cuadro sostenido I de `DSHD` y `LHND` se amplía al 118 % sobre un
  pivote compartido; no se regenera.
- La inclinación final de la espada se realiza con
  `A_OverlayPivot`/`A_OverlayRotate`; no se redibuja la hoja.
- Los tres momentos del golpe reutilizan el cuadro A y sólo cambian offsets;
  no se generan cuadros de ataque distintos.

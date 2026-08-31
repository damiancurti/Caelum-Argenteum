# Zupay Colosal del Socavón — paquete v2

Enemigo bípedo de tres metros inspirado libremente en el imaginario minero y en
figuras demoníacas del folclore criollo del noroeste argentino. El diseño conserva
roca volcánica, sal, tejidos de altura, cobre envejecido, cadena y campana de
socavón. Es una adaptación de fantasía oscura, no una reproducción ceremonial.

## Contenido

- `ca_enemy_zupay_colossus_sprite_sheet.png`: atlas principal, 54 cuadros.
- `ca_enemy_zupay_colossus_object_actions.png`: recoger y arrojar, 48 cuadros.
- `frames/`: 102 PNG individuales con nombres definitivos.
- `zupay_colossus_manifest.json`: orden, coordenadas y metadatos de integración.

## Tamaño y formato

- PNG RGBA de 32 bits con transparencia real.
- Cada cuadro: 416 × 416 px.
- Silueta útil erguida: aproximadamente 384 px.
- Origen visual sugerido: `(208, 400)`, centro inferior de la celda.
- Atlas principal: 2496 × 3744 px, 6 columnas × 9 filas.
- Atlas de objetos: 2496 × 3328 px, 6 columnas × 8 filas.

Se usan dos atlas porque una hoja única con los 102 cuadros excedería el límite
habitual de 4096 px por eje. Los 416 px de celda derivan de mantener la misma
densidad visual que los personajes humanos de 256 px: una silueta humana de unos
230 px a 1,8 m escala a `230 × (3 / 1,8) = 383,33 px` para un enemigo de 3 m; se
redondea a 384 px y se reserva margen de seguridad.

## Atlas principal

Columnas: `idle`, `walk_a`, `walk_b`, `attack_windup`, `attack_strike`, `pain`.

Filas 1–8: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`,
`right`, `front_right`. La fila 9 contiene la muerte compartida en seis etapas.

## Atlas de recoger y arrojar

Las ocho filas usan el mismo orden direccional. Columnas:

1. `lift_reach`: se agacha y toma la roca.
2. `lift_raise`: inicia el levantamiento.
3. `lift_hold`: asegura la roca contra el torso.
4. `throw_windup`: eleva la roca sobre la cabeza.
5. `throw_release`: completa el gesto de lanzamiento.
6. `throw_recover`: recupera el equilibrio con las manos vacías.

Hay exactamente una roca en los cuadros 1–5 y ninguna en el cuadro 6. Crear el
proyectil del juego al pasar de `throw_release` a `throw_recover`; así la roca no
aparece simultáneamente en la mano y en vuelo.

## Integración

- Importar sin reescalar; la diferencia de tamaño ya está dibujada en píxeles.
- Mantener el mismo `Scale` visual usado por los personajes humanos.
- No usar los 416 px completos como radio de colisión: medir torso y hombros.
- Si 1,8 m equivale a 56 MU, 3 m equivale proporcionalmente a 93,33 MU; ajustar
  el redondeo a la convención de colisiones del proyecto.
- Usar filtrado lineal o trilineal. Ante halos, revisar mipmaps y alfa antes de
  modificar las imágenes.
- El sexto cuadro de muerte puede permanecer como estado final.

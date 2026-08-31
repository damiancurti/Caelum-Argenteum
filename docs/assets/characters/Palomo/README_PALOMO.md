# Palomo — paquete de sprites v3

Esta versión conserva el diseño aprobado de Palomo —hombre bestia paloma,
galera negra con banda plateada, monóculo en el ojo derecho y vestuario
argentino del siglo XIX— y reconstruye todas sus emociones en ocho direcciones.

## Contenido

- `ca_palomo_sprite_sheet.png`: hoja base sin cambios, con 32 cuadros.
- `emotions/ca_palomo_emotion_laugh.png`: risa, 32 cuadros.
- `emotions/ca_palomo_emotion_anger.png`: enojo, 32 cuadros.
- `emotions/ca_palomo_emotion_joy.png`: alegría, 32 cuadros.
- `emotions/ca_palomo_emotion_surprise.png`: sorpresa, 32 cuadros.
- `emotions/ca_palomo_emotion_sadness.png`: tristeza, 32 cuadros.
- `emotions/ca_palomo_emotion_thought.png`: pensamiento/sospecha, 32 cuadros.
- `frames/base/`: los 32 cuadros base individuales.
- `frames/emotions/`: los 192 cuadros emocionales individuales.

Total del paquete: **224 cuadros**.

## Formato

- PNG RGBA con transparencia real.
- Cada cuadro mide `256 × 256 px`.
- Escala óptica máxima: `232 × 236 px`.
- Margen inferior transparente: `10 px`.
- Cada atlas mide `1024 × 2048 px`.
- Cada atlas usa una cuadrícula de 4 columnas × 8 filas.

Las seis emociones se entregan como atlas separados porque una única hoja con
las 192 poses mediría `1024 × 12288 px`, una altura inconveniente para el motor
y superior al límite común de muchas GPU. Las hojas individuales de 2048 px de
alto son más seguras de cargar, reemplazar y depurar.

## Orden de la cuadrícula emocional

Las cuatro columnas son las etapas `1`, `2`, `3` y `4` de cada emoción.

Las ocho filas son:

1. `front` — frente directo, 0°.
2. `front_left` — diagonal frontal izquierda, 45°.
3. `left` — perfil izquierdo, 90°.
4. `back_left` — diagonal posterior izquierda, 135°.
5. `back` — espalda directa, 180°.
6. `back_right` — diagonal posterior derecha, 225°.
7. `right` — perfil derecho, 270°.
8. `front_right` — diagonal frontal derecha, 315°.

En `front`, pico, ojos, hombros, torso y cadera miran directamente al jugador.
Los cuadros intermedios pueden incluir un movimiento breve de cabeza, pero el
torso no gira a 3/4. En las vistas posteriores, la emoción se comunica mediante
hombros, brazos y postura; no aparece un rostro frontal artificial.

## Nombres individuales

Los cuadros emocionales siguen este patrón:

`ca_palomo_<emotion>_<direction>_<frame>.png`

Ejemplos:

- `ca_palomo_laugh_front_3.png`
- `ca_palomo_anger_back_left_2.png`
- `ca_palomo_thought_right_4.png`

## Reproducción sugerida

- Risa: 7 FPS; puede repetirse `1 → 2 → 3 → 2 → 4`.
- Enojo: 6 FPS; reproducir una vez y sostener el cuadro 4.
- Alegría: 6 FPS; reproducir una vez o en un bucle suave.
- Sorpresa: 8 FPS; reproducir una vez y sostener brevemente el cuadro 3.
- Tristeza: 4 FPS; reproducir una vez y sostener el cuadro 4.
- Pensamiento: 5 FPS; puede repetirse lentamente.

Para escenas de diálogo, seleccionar primero la fila que corresponde al ángulo
real entre Palomo y el jugador; no forzar siempre la fila frontal. Mantener el
filtrado lineal/bilineal acordado y evitar un segundo reescalado durante la
importación.


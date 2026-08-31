# Mandinga de la Salamanca — sprites de Caelum Argenteum

Enemigo demoníaco de inspiración criolla argentina: poncho corto, bombachas de campo,
rastra plateada, botas con espuelas y facón. La piel de carbón, las fisuras de brasa y
los cuernos dejan claro que se trata de una criatura sobrenatural y no de una persona.

## Archivos

- `ca_enemy_mandinga_sprite_sheet.png`: atlas listo para integrar.
- `frames/`: los 54 cuadros individuales, todos con su nombre definitivo.
- `mandinga_manifest.json`: posiciones, orden y dimensiones para carga automática.

## Formato técnico

- PNG RGBA de 32 bits con transparencia real.
- Cada cuadro mide 256 × 256 px.
- Atlas de 1536 × 2304 px: 6 columnas × 9 filas.
- Punto de apoyo visual sugerido: (128, 248), centro inferior de cada celda.
- No escalar los PNG al importarlos. Aplicar el escalado de mundo desde el motor.
- Filtrado sugerido: lineal o trilineal para vista normal; desactivar mipmaps solo si
  producen halos en la escala final del proyecto.

## Orden del atlas

Columnas, de izquierda a derecha:

1. `idle`
2. `walk_a`
3. `walk_b`
4. `attack_windup`
5. `attack_strike`
6. `pain`

Filas, de arriba hacia abajo:

1. `front` (0°)
2. `front_left` (45°)
3. `left` (90°; el personaje mira hacia la derecha de pantalla)
4. `back_left` (135°)
5. `back` (180°)
6. `back_right` (225°)
7. `right` (270°; el personaje mira hacia la izquierda de pantalla)
8. `front_right` (315°)
9. muerte compartida, cuadros 1–6

## Animación sugerida

- Reposo: mantener `idle` entre 180 y 260 ms por cuadro si se añade respiración desde código.
- Marcha: alternar `walk_a` y `walk_b`, 110–150 ms por cuadro.
- Ataque: `attack_windup` 140–190 ms y `attack_strike` 80–120 ms; aplicar el daño en `attack_strike`.
- Dolor: `pain` 120–180 ms y volver al estado anterior.
- Muerte: cuadros 1–6 a 110–160 ms; conservar indefinidamente el sexto cuadro.

Los tiempos son una base de integración y pueden ajustarse a la velocidad real del actor.

# Caelum Argenteum — Primera persona de Domingo V4.32.0f

## Alcance

Los sprites corregidos de Domingo ya no viven en un arma especial de consola.
V4.32.0f los conecta directamente con `CaelumSwordSelectorWeapon`, el selector
de la espada que el jugador equipa desde el inventario real. No existe una
segunda espada, un daño de prueba ni una ruta paralela de bloqueo.

La integración sólo reemplaza la presentación de esa espada. Fire, AltFire,
Zoom/Block, Reload y User1–User4 conservan las funciones autoritativas de
`CaelumPhysicalSelectorWeapon` y `CaelumPlayer`, incluidos daño, Aire,
enfriamiento, durabilidad, sonidos y restricciones de equipo.

Mientras este selector está activo, el HUD omite su icono provisional de arma y
su antiguo dibujo provisional de bloqueo para no superponerlos a los PSprites.
Los demás tipos de arma conservan la presentación anterior.

## Recursos integrados

- Los 45 PNG de 320×200 de la revisión 2 recibida reemplazan la entrega
  anterior: 36 módulos `LHND`, `DSHD`, `DSWD` y `RHND`, más nueve composiciones
  de referencia `DFPR`, `DFPS`, `DFPA` y `DFPB`.
- Nueve PNG nuevos `RFNG` A–I contienen únicamente las zonas de dedos que
  deben pasar por delante del mango. Se extrajeron de los cuadros `RHND`
  corregidos sin recolorear ni regenerar el guante.
- Los 54 archivos son RGBA de 8 bits, miden 320×200 y comparten el offset PNG
  `grAb` X=160, Y=32. Los hashes están en
  `DOMINGO_FP_4_32_0f_SHA256.txt`.
- Los compuestos suministrados se conservan como referencia artística, pero la
  vista ejecutable utiliza las capas separadas.

## Profundidad y alineación

| Capa | Prefijo | Contenido | Regla |
| ---: | --- | --- | --- |
| 10 | `DSHD` | Reverso del escudo | Sólo con escudo válido equipado |
| 20 | `LHND` | Mano/brazo que sostiene el escudo | Se oculta junto con el escudo |
| 25 | `RHND` | Antebrazo, palma y base del puño | Detrás de la espada |
| 30 | `DSWD` | Espada | Atraviesa el centro del agarre |
| 40 | `RFNG` | Dedos de cierre | Delante del mango |

Este orden corrige el agarre sin desplazar arbitrariamente una capa completa:
la palma queda detrás del arma y los dedos vuelven a cubrir sólo los tramos del
mango que deben sujetar. Todas las capas mantienen el mismo lienzo y pivote en
los nueve cuadros, por lo que reposo, cambio, ataque y bloqueo no pierden
registro entre sí.

## Escudo condicional

El escudo y la mano izquierda sólo se crean cuando
`CaelumPlayer.HasActiveBlockSource()` confirma, con la espada activa, un escudo
equipado, compatible y con durabilidad positiva. Si el jugador desequipa el
escudo, éste se rompe o deja de ser compatible, ambas capas se eliminan en el
siguiente tic. Volver a equipar uno las reconstruye sin cambiar de espada.

Zoom continúa siendo el interruptor real de Block. Al activarlo se reproduce
H→I y el cuadro I permanece mientras el modo siga activo; al desactivarse,
agotarse una condición válida o atacar, la vista vuelve a reposo/ataque de
acuerdo con el estado real. Sin escudo no se puede entrar en Block y no aparece
ningún escudo visual.

## Cuadros conectados

| Cuadro | Uso |
| --- | --- |
| A–B | Reposo y oscilación |
| C–D | Sacar la espada; D–C al guardarla |
| E–G | Ataque primario o secundario aceptado por la mecánica real |
| H–I | Alzar y sostener Block real |

La animación de ataque sólo comienza si la llamada autoritativa inicia un
enfriamiento nuevo. Un ataque rechazado por enfriamiento, falta de Aire,
durabilidad, menú o inmovilización no reinicia falsamente E–G.

## Prueba dentro del juego

No usar `give CA_DomingoFPSwordShield`: esa clase ya no existe. Equipar una
espada normal desde el inventario y seleccionarla con la tecla de su familia.

Comprobar, con y sin escudo, reposo A–B, ataque E–G, Zoom H–I y cambio C–D en
4:3, 16:9, 16:10 y ultrawide. La revisión sigue siendo un prototipo visual:
encuadre, bob y tiempos pueden ajustarse después de la prueba, pero la jerarquía
palma/espada/dedos y la condición de escudo ya forman parte del contrato.

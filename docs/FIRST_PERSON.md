# Caelum Argenteum — Prototipo de primera persona V4.32.0e

## Alcance

Esta versión integra el prototipo visual suministrado para Domingo sin
convertirlo todavía en la presentación definitiva del equipamiento. La clase
de prueba `CA_DomingoFPSwordShield` sólo se obtiene por consola y queda aislada
de los selectores normales. No modifica daño real, bloqueo real, Aire,
durabilidad, recetas, inventario, modelos ni sonidos.

Mientras el prototipo está seleccionado, el HUD omite únicamente sus dos
representaciones provisionales —el icono de arma activa y el escudo de bloqueo—
para no dibujarlas encima de los PSprites nuevos.

## Recursos integrados

- 45 PNG de motor, todos de 320×200, RGBA de 8 bits y offset `grAb` X=160,
  Y=32.
- 36 capas modulares: `LHND`, `DSHD`, `DSWD` y `RHND`, con cuadros A–I.
- Nueve composiciones `DFPR`, `DFPS`, `DFPA` y `DFPB`, conservadas como
  referencia alternativa aunque la clase de prueba usa las capas modulares.
- Los 45 archivos de `runtime/sprites` son idénticos byte por byte a los del
  ZIP recibido. Sus hashes están en `DOMINGO_FP_4_32_0e_SHA256.txt`.

Los maestros 640×400 y las previsualizaciones permanecen en el paquete de arte
original. No se duplican en el runtime porque GZDoom sólo necesita los PNG de
motor y el usuario indicó que éste es un prototipo sujeto a ajustes.

## Capas y cuadros

| Capa | Prefijo | Contenido |
| ---: | --- | --- |
| 10 | `LHND` | Brazo izquierdo |
| 20 | `DSHD` | Escudo solar de Domingo |
| 30 | `DSWD` | Espada |
| 40 | `RHND` | Brazo y mano derechos |

| Cuadro | Uso actual |
| --- | --- |
| A–B | Reposo/oscilación |
| C–D | Aparición |
| E–G | Ataque de prueba |
| H–I | Bloqueo visual |

## Prueba dentro del juego

Abrir la consola en una partida y ejecutar:

```text
give CA_DomingoFPSwordShield
use CA_DomingoFPSwordShield
```

- Fire reproduce el tajo y usa un `A_CustomPunch(30, true)` exclusivamente
  para sentir la animación de esta arma de prueba.
- AltFire alza y sostiene brevemente el escudo, pero no reduce daño ni consume
  Aire.
- Cambiar a un arma real debe limpiar las cuatro capas y restaurar el HUD
  provisional habitual.

Revisar el encuadre y el movimiento en 4:3, 16:9, 16:10 y ultrawide. Los
ajustes posteriores deben conservar un origen común entre las cuatro capas;
no debe corregirse el offset de una pieza de manera independiente.

## Puerta de integración definitiva

Antes de vincular este arte al inventario real hay que aprobar encuadre, bob,
velocidades de aparición/ataque/bloqueo, solapamiento con HUD y comportamiento
al cambiar de arma. Después podrá conectarse por módulos a tipo/tier de arma,
escudo equipado y vestimenta, reutilizando las mecánicas autoritativas ya
existentes en lugar del golpe de prueba.

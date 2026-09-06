# Caelum Argenteum — Primera persona de Domingo V4.32.0h

## Alcance

La vista modular continúa conectada exclusivamente con
`CaelumSwordSelectorWeapon`, la espada real equipada desde el Inventario. No
existe un arma especial de prueba ni una segunda ruta de daño o bloqueo.

V4.32.0h reemplaza la propuesta visual V4.32.0g después de la prueba del autor.
No modifica Fire, AltFire, Zoom/Block, Aire, enfriamiento, durabilidad, sonidos,
persistencia, equipo, HUD, mapas ni diálogos. Todo ese comportamiento permanece
en las rutas autoritativas de `CaelumPlayer` ya aprobadas.

## Encuadre por estado

Las capas ya no comparten una única X:

| Estado | Escudo/mano izquierda (10/20) | Brazo/espada/dedos (25/30/40) |
| --- | ---: | ---: |
| Reposo y ataque | X=105 | X base=160 |
| Block | X=160 | X=160 |

Por eso el escudo queda claramente lateral en reposo, sin arrastrar la espada
hacia la izquierda. Al entrar en Block vuelve al centro. Todos los valores Y
base siguen en 0 y conservan el alzado, descenso y bob del selector real.

## Block frontal y sostenido

H sigue siendo la transición breve de alzar el escudo durante tres tics. I ya
no vuelve a H: usa duración `-1` y queda fijo hasta que el estado real de Block
termine. Esto elimina el ciclo H/I que hacía oscilar continuamente el escudo.

El escudo y el brazo izquierdo del cuadro I se ampliaron juntos al 118 % sobre
el mismo pivote. El resultado es una pose más cercana a la cara, frontal y
perpendicular a la cámara, sin perder la alineación de la mano con la
empuñadura. Los lienzos I son 360×240 y usan `grAb (160,48)` para conservar la
posición lógica pese al margen adicional.

## Espada casi vertical

La hoja conserva el arte de V4.32.0g, pero el motor aplica una rotación absoluta
de 30 grados alrededor de la empuñadura (`pivot 0.55625, 0.83`). La pose queda
casi a 90 grados y el mango continúa entre la palma `RHND` y los dedos `RFNG`.
La rotación es absoluta, no acumulativa, y se reaplica al sincronizar las capas.

## Ataque de avance y retroceso

E/F/G ya no cambian de dibujo ni de ángulo. Las tres fases muestran la misma
pose A y sólo trasladan de forma conjunta el brazo, la espada y los dedos:

| Fase | Tics | X | Y | Función visual |
| --- | ---: | ---: | ---: | --- |
| Preparación | 2 | 174 | 8 | Alejar la mano |
| Extensión | 3 | 132 | -18 | Acercar la mano |
| Recuperación | 3 | 148 | -7 | Regresar hacia reposo |
| Reposo | — | 160 | 0 | Posición base |

El movimiento resulta equivalente a un avance–retroceso de arma en primera
persona: la hoja no se vuelca ni barre la pantalla cambiando de inclinación.
El escudo y su mano permanecen en la pose lateral A durante esos ocho tics.

## Manga panorámica extendida

`RHNDA0` se reconstruyó sobre un maestro RGBA de 960×480. Se conservó el puño y
el agarre originales y se prolongaron únicamente brazal, tela y manga hacia el
borde derecho. La exportación de motor mide 480×240, usa `grAb (160,72)` y llega
al extremo del lienzo. `RHNDB0` es la oscilación registrada un píxel abajo y a
la derecha. Así el avance del ataque no revela un corte vertical antes del
borde de una vista 16:9.

## Profundidad y condición de equipo

| Capa | Prefijo | Contenido | Regla |
| ---: | --- | --- | --- |
| 10 | `DSHD` | Reverso del escudo | Sólo con escudo válido equipado |
| 20 | `LHND` | Mano/brazo que sostiene el escudo | Se oculta junto con el escudo |
| 25 | `RHND` | Antebrazo, palma y base del puño | Detrás de la espada |
| 30 | `DSWD` | Espada | Atraviesa el centro del agarre |
| 40 | `RFNG` | Dedos de cierre | Delante del mango |

`HasActiveBlockSource()` continúa siendo la única condición visual del escudo.
Si se desequipa, se rompe o deja de ser compatible, `DSHD` y `LHND` desaparecen
en el siguiente tic. Sin un escudo válido no se muestra el arte ni se habilita
Block.

## Estado de prueba

La auditoría automática comprueba estructura ZScript, delta acotado, dimensiones,
RGBA, offsets `grAb`, hashes y contenido exacto del ZIP fuente. La aceptación
visual dentro de GZDoom 4.14.2 queda pendiente con
`PRUEBAS_4_32_0h.txt`; no es necesario repetir los sistemas no visuales ya
aprobados.

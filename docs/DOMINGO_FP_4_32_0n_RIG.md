# V4.32.0n — elevación, pulgar completo y rig sincronizado

> Estado histórico: V4.32.0o conserva la elevación y el pulgar completo, pero
> reemplaza los pivotes de `RHND`/`RFNG`. V4.32.0n los calculaba sobre el
> lienzo PNG; GZDoom los evaluó sobre cajas visibles distintas y separó ambas
> capas durante uno de los cuadros de giro.

## Decisiones aplicadas

1. La espada sube cuatro unidades lógicas: reposo (260,0) y registro constante
   (-22,-32) durante los ocho tics del ataque.
2. La capa frontal `RFNG` cubre ahora todo el pulgar. Los píxeles nuevos se
   toman de la misma pose `RHND`, de modo que color, contorno y sombreado
   pertenecen al arte original de Domingo.
3. Mano, espada y pulgar rotan sobre un punto visual compartido. La espada
   conserva sus valores absolutos y las capas corporales usan sólo la diferencia
   respecto de los 18° de reposo.
4. El Block de V4.32.0m no se modifica.

## Registro del pivote

Los pivotes locales se eligieron de modo que, después de compensar el `grAb` y
el offset propio de cada capa, todos representen el punto relativo (-4,102):

| Capa | Pivote local | Cálculo relativo |
| ---: | ---: | --- |
| 25 `RHND` | (156,174) | (156-160, 174-72) = (-4,102) |
| 30 `DSWD` | (178,166) | (178-160-22, 166-32-32) = (-4,102) |
| 40 `RFNG` | (156,134) | (156-160, 134-32) = (-4,102) |

En ZScript se expresan como (0.325,0.725), (0.55625,0.83) y
(0.4875,0.67), respectivamente.

## Secuencia sincronizada

| Estado | Mano/dedos | Espada | Giro mano/dedos | Giro espada |
| --- | ---: | ---: | ---: | ---: |
| Reposo | (282,32) | (260,0) | 0° | 18° |
| Salida | (300,15) | (278,-17) | 3° | 21° |
| Ápice | (318,-4) | (296,-36) | 6° | 24° |
| Barrido | (287,-1) | (265,-33) | 13° | 31° |
| Aproximación | (236,11) | (214,-21) | 20° | 38° |
| Impacto | (201,21) | (179,-11) | 25° | 43° |
| Retorno 1 | (228,25) | (206,-7) | 21° | 39° |
| Retorno 2 | (255,28) | (233,-4) | 13° | 31° |
| Retorno 3 | (275,31) | (253,-1) | 6° | 24° |

La regla es `giro_mano = giro_espada - 18°`. Ninguna rotación es incremental:
cada cuadro escribe su valor final, evitando deriva entre ataques.

## Prueba de la máscara del pulgar

- `RFNGA0`: caja alfa inclusiva (148,92)–(210,151).
- `RFNGB0`: caja alfa inclusiva (149,93)–(211,152).
- A conserva byte por byte todos los píxeles visibles anteriores y añade 443
  píxeles sobre zonas antes transparentes: 413 copias RGBA exactas de `RHNDA0`
  y 30 con el mismo RGB y alfa reducido únicamente en el borde suavizado.
- B es exactamente A desplazada (+1,+1); sus maestros 2× conservan la misma
  relación con desplazamiento (+2,+2).
- Los colores añadidos coinciden con el pulgar de `RHNDA0`; la única diferencia
  admitida es el alfa menor de esos 30 píxeles de contorno, no una textura
  recreada.

## Límite del parche

El cambio se restringe a `CaelumSwordSelectorWeapon`, `RFNGA0`, `RFNGB0`, sus
maestros 2× y documentación. No altera el daño, los estados autoritativos de
Block, la resistencia del escudo, el Aire, la durabilidad ni otro sistema del
juego.

# Caelum Argenteum — Primera persona de Domingo V4.32.0o

## Alcance

La vista modular continúa conectada exclusivamente con
`CaelumSwordSelectorWeapon`, la espada real equipada desde el Inventario. No
existe un arma especial de prueba ni una segunda ruta de daño o bloqueo.

V4.32.0o conserva la altura, el pulgar completo y la trayectoria de V4.32.0n,
pero corrige el cuadro que mostraba dos puños. El código anterior calculó los
pivotes con el tamaño completo del PNG; GZDoom aplica `PSPF_PIVOTPERCENT` a la
caja visible de cada textura. Como `RHND`, `DSWD` y `RFNG` tienen cajas alfa
distintas, las dos representaciones complementarias de la misma mano se
separaban al girar. Los nuevos porcentajes compensan esas cajas y hacen que
las tres transformaciones resuelvan al pivote real ya usado por la espada.
No modifica sprites, daño, Aire, enfriamiento, durabilidad, sonidos,
persistencia, equipo, HUD, mapas, economía, Palomo ni diálogos.

## Encuadre por estado

| Estado | Escudo (10) | Mano izquierda (20) | Mano/dedos derechos (25/40) | Espada (30) |
| --- | ---: | ---: | ---: | ---: |
| Reposo | X=82, Y=45 | X=82, Y=45 | X=282, Y=32 | X=260, Y=0 |
| Block sostenido | X=160, Y=100 | X=160, Y=100 | Ocultas | Oculta |

En reposo, escudo y mano izquierda continúan juntos en la marca inferior
izquierda aceptada. La palma y el pulgar derechos permanecen en (282,32). La
espada pasa de (260,4) a (260,0), por lo que sube ligeramente sin cambiar su
registro horizontal aprobado.

## Block frontal, cercano y sostenido

El Block no cambia respecto de V4.32.0m. H sigue siendo una transición breve
de tres tics e I usa duración `-1`, fija hasta terminar el estado real de
Block. El escudo y su mano correcta permanecen en las capas 10 y 20 a
(160,100); las capas de la mano hábil 25/30/40 se limpian para evitar una
segunda mano. Al soltar Block, el conjunto derecho se reconstruye de inmediato.

La exportación `DSHDI0` conserva 450×300, `grAb (225,48)` y una caja visible
de 293×244. `LHNDI0` comparte lienzo y origen y conserva su caja visible de
213×169. No cambian perspectiva, tamaño, altura ni condición de equipo.

## Pulgar completo delante del mango

`RFNGA0` y `RFNGB0` mantienen lienzo RGBA 320×200 y `grAb (160,32)`, pero la
máscara frontal ahora incluye todo el pulgar visible que ya existe en la capa
de mano `RHND`. La ampliación A añade exactamente 443 píxeles visibles con el
color original de Domingo: 413 conservan también su alfa exacto y 30 reducen
sólo el alfa en el borde suavizado de la máscara. No repinta ni desplaza ningún
píxel que ya pertenecía a `RFNG`. B es la misma pose desplazada exactamente
(+1,+1), tal como ocurre entre `RHNDA0` y `RHNDB0`.

La caja alfa inclusiva pasa a (148,92)–(210,151) en A y
(149,93)–(211,152) en B. De este modo, el mango queda detrás del pulgar entero
y ya no parece cortar el dedo.

## Giro sincronizado sin duplicación

La espada conserva exactamente su pivote y movimiento aceptados. Para mano y
pulgar, los porcentajes se calculan sobre sus cajas alfa reales, no sobre el
lienzo transparente. El resultado de cada fila, después de compensar `grAb` y
el desplazamiento espada–mano (-22,-32), es el mismo punto de pantalla
(56.64375,84.57):

| Capa | Caja alfa A / tamaño | Pivote porcentual | Punto efectivo del PNG | Punto de pantalla común |
| ---: | --- | ---: | ---: | ---: |
| 25 `RHND` | (147,128)–(479,239) / 333×112 | (0.2091403904, 0.2550892857) | (216.64375,156.57) | (56.64375,84.57) |
| 30 `DSWD` | (168,0)–(294,178) / 127×179 | (0.55625, 0.83) | (238.64375,148.57) | (56.64375,84.57) |
| 40 `RFNG` | (148,92)–(210,151) / 63×60 | (1.0895833333, 0.4095) | (216.64375,116.57) | (56.64375,84.57) |

El X de `RFNG` supera 1 porque el punto compartido queda apenas fuera de su
caja visible; el motor permite pivotes porcentuales fuera del intervalo
0–1. La compensación mantiene los tres píxeles de anclaje coincidentes hasta
el máximo giro y elimina la silueta duplicada del puño.

La hoja conserva sus ángulos absolutos. La mano y el pulgar reciben solamente
la variación respecto del reposo: `rotación_mano = rotación_espada - 18°`.
Así, el arte de la mano no cambia en reposo y durante el ataque acompaña tanto
la posición como el giro de la espada sin perder el agarre.
El delta total de la mano va de 0→25° entre reposo e impacto.

| Momento | Hoja absoluta | Mano/pulgar | Ángulo visual aproximado |
| --- | ---: | ---: | ---: |
| Reposo | 18° | 0° | 79° |
| Salida 1 | 21° | 3° | 82° |
| Ápice | 24° | 6° | 85° |
| Barrido 1 | 31° | 13° | 92° |
| Barrido 2 | 38° | 20° | 99° |
| Impacto | 43° | 25° | 104° |
| Retorno 1 | 39° | 21° | 100° |
| Retorno 2 | 31° | 13° | 92° |
| Retorno 3 | 24° | 6° | 85° |
| Reposo recuperado | 18° | 0° | 79° |

Cada valor es absoluto y se reaplica durante la sincronización; no se acumula
entre tics.

## Curva de ataque y retorno recto

Los ocho tics continúan reutilizando la pose A. Cinco puntos llevan la mano
por la curva aprobada hasta el impacto y tres puntos colineales la devuelven en
línea recta. La espada mantiene en todo momento el registro constante
(-22,-32) respecto de la traslación de palma y pulgar:

| Tic | Fase | Mano/dedos X,Y | Espada X,Y | Hoja / mano |
| ---: | --- | ---: | ---: | ---: |
| 1 | Salida | (300,15) | (278,-17) | 21° / 3° |
| 2 | Ápice derecho | (318,-4) | (296,-36) | 24° / 6° |
| 3 | Barrido alto | (287,-1) | (265,-33) | 31° / 13° |
| 4 | Aproximación | (236,11) | (214,-21) | 38° / 20° |
| 5 | Impacto izquierdo | (201,21) | (179,-11) | 43° / 25° |
| 6 | Retorno 1 | (228,25) | (206,-7) | 39° / 21° |
| 7 | Retorno 2 | (255,28) | (233,-4) | 31° / 13° |
| 8 | Retorno 3 | (275,31) | (253,-1) | 24° / 6° |
| — | Reposo | (282,32) | (260,0) | 18° / 0° |

La subida uniforme de cuatro unidades afecta únicamente a la hoja; no altera
la curva de la mano ni el retorno recto ya aceptados.

## Manga panorámica, profundidad y equipo

`RHNDA0` y `RHNDB0` conservan los lienzos RGBA 480×240 con `grAb (160,72)`
aceptados en V4.32.0h. La manga llega al extremo derecho del lienzo y no revela
un corte interno en 16:9.

| Capa | Prefijo | Contenido | Regla |
| ---: | --- | --- | --- |
| 10 | `DSHD` | Reverso del escudo | Sólo con escudo válido equipado |
| 20 | `LHND` | Mano/brazo del escudo | Visible con el escudo, incluido Block |
| 25 | `RHND` | Antebrazo, palma y base del puño | Oculta en Block; detrás de la espada fuera de él |
| 30 | `DSWD` | Espada | Oculta en Block; atraviesa el agarre fuera de él |
| 40 | `RFNG` | Pulgar y dedos de cierre | Ocultos en Block; delante del mango fuera de él |

`HasActiveBlockSource()` continúa siendo la única condición visual del escudo.
Si se desequipa, se rompe o deja de ser compatible, `DSHD` y `LHND`
desaparecen en el siguiente tic. Sin escudo válido no se muestra el arte ni se
habilita Block.

## Estado de prueba

La auditoría automática comprueba estructura ZScript, delta acotado,
dimensiones RGBA, offsets `grAb`, cajas alfa, hashes, ampliación exacta del
pulgar, desplazamiento A→B, pivote de pantalla común, rotación sincronizada,
registro (-22,-32), Block correcto y contenido reproducible del ZIP fuente.
La aceptación visual dentro de GZDoom 4.14.2 queda pendiente con
`PRUEBAS_4_32_0o.txt`; no es necesario repetir los sistemas no visuales ya
aprobados.

# Caelum Argenteum — Primera persona de Domingo V4.32.0j

## Alcance

La vista modular continúa conectada exclusivamente con
`CaelumSwordSelectorWeapon`, la espada real equipada desde el Inventario. No
existe un arma especial de prueba ni una segunda ruta de daño o bloqueo.

V4.32.0j reemplaza solamente el encuadre de manos de V4.32.0i según la captura
marcada por el autor y corrige la orientación de la mano visible al bloquear.
No modifica Fire, AltFire, Zoom/Block, Aire, enfriamiento, durabilidad, sonidos,
persistencia, equipo, HUD, mapas ni diálogos. Todo ese comportamiento permanece
en las rutas autoritativas de `CaelumPlayer` ya aprobadas.

## Encuadre por estado

| Estado | Escudo (10) | Mano izquierda (20) | Brazo/espada/dedos (25/30/40) |
| --- | ---: | ---: | ---: |
| Reposo | X=105, Y=0 | X=82, Y=45 | X=288, Y=28 |
| Preparación | X=105, Y=0 | X=82, Y=45 | X=302, Y=36 |
| Extensión | X=105, Y=0 | X=82, Y=45 | X=260, Y=10 |
| Recuperación | X=105, Y=0 | X=82, Y=45 | X=276, Y=21 |
| Block sostenido | X=160, Y=100 | X=160, Y=100 | X=160, Y=0 |

El escudo sigue claramente lateral en reposo y conserva exactamente su
encuadre aprobado. La mano izquierda ya no comparte su offset: baja 45 unidades
y se desplaza 23 a la izquierda hasta la marca azul. Mano derecha, espada y
dedos se trasladan juntos 128 unidades a la derecha y 46 hacia abajo respecto
de V4.32.0i. El mango no se desregistra entre capas.

## Block frontal, cercano y sostenido

H sigue siendo la transición breve de tres tics. I usa duración `-1` y queda
fijo hasta que termine el estado real de Block; no existe un ciclo H/I. El
escudo, su escala y sus offsets permanecen byte por byte y valor por valor
iguales a V4.32.0i.

El cuadro I del escudo se reconstruyó como una vista ortogonal del reverso:
plano perpendicular a la cámara, aro circular, tablones verticales y sin la
perspectiva oblicua heredada. El arte compensa en X el pixel aspect 1,2 de Doom,
por lo que su exportación parece ancha en el PNG pero recupera un círculo en
pantalla.

La exportación `DSHDI0` mide 450×300, usa `grAb (225,48)` y tiene una caja
visible de 293×244. Los 244 píxeles verticales representan el aumento lineal
solicitado: 244/195 = 1,251 respecto del cuadro I de V4.32.0h. Los 293 píxeles
horizontales neutralizan la relación 1,2 del motor (293/244 = 1,201), no son un
segundo aumento de distancia. `LHNDI0` comparte lienzo y origen; su caja visible
213×169 también equivale, con redondeo de ráster, al 125 % de los 170×135
anteriores y permanece registrada con el nuevo agarre.

La mano horizontal que queda visible bajo el escudo proviene de las capas de
Block `RHND`/`DSWD`/`RFNG`. Sus cuadros H/I ahora son reflejos horizontales
exactos y conjuntos, de modo que el antebrazo entra desde la izquierda sin
alterar el registro entre palma, transición de espada y dedos.

## Ángulo y altura de la espada

La hoja conserva el arte acumulativo de V4.32.0g y el pivote de empuñadura
`(0.55625, 0.83)`. El dibujo aporta aproximadamente 61 grados antes de la
rotación del motor. V4.32.0j conserva los ángulos absolutos aprobados:

| Momento | Rotación del motor | Ángulo visual aproximado |
| --- | ---: | ---: |
| Reposo | 18° | 79° |
| Preparación | 24° | 85° |
| Impacto/extensión | 43° | 104° |
| Recuperación | 31° | 92° |

Así el reposo queda dentro del intervalo 75–80° indicado por el autor y el
golpe cruza ligeramente la vertical dentro del intervalo 95–110°. Cada valor
es absoluto, no acumulativo, y se reaplica durante la sincronización.

## Ataque de avance, inclinación y retroceso

Las tres fases continúan reutilizando la pose A. El movimiento principal sigue
siendo acercar y alejar la mano al estilo Hexen; la variación angular acompaña
ese avance sin volver a usar el vuelco de los cuadros E/F/G.

| Fase | Tics | X | Y | Rotación |
| --- | ---: | ---: | ---: | ---: |
| Preparación | 2 | 302 | 36 | 24° |
| Extensión | 3 | 260 | 10 | 43° |
| Recuperación | 3 | 276 | 21 | 31° |
| Reposo | — | 288 | 28 | 18° |

Los desplazamientos conservan exactamente las diferencias de avance y
retroceso de V4.32.0i alrededor de la nueva base (288,28). El escudo permanece
en su pose lateral A y la mano izquierda en (82,45) durante esos ocho tics.

## Manga panorámica extendida

`RHNDA0` y `RHNDB0` conservan sin cambios los lienzos RGBA 480×240 con
`grAb (160,72)` aceptados en V4.32.0h. La manga llega al extremo derecho del
lienzo, por lo que el avance no revela un corte interno en 16:9.

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

La auditoría automática comprueba estructura ZScript, delta acotado,
dimensiones RGBA, offsets `grAb`, cajas alfa, proporciones, hashes, los seis
reflejos píxel por píxel y el contenido exacto del ZIP fuente. La aceptación
visual dentro de GZDoom 4.14.2 queda pendiente con `PRUEBAS_4_32_0j.txt`; no es
necesario repetir los sistemas no visuales ya aprobados.

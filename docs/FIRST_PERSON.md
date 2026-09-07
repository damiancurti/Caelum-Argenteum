# Caelum Argenteum — Primera persona de Domingo V4.32.0k

## Alcance

La vista modular continúa conectada exclusivamente con
`CaelumSwordSelectorWeapon`, la espada real equipada desde el Inventario. No
existe un arma especial de prueba ni una segunda ruta de daño o bloqueo.

V4.32.0k corrige la interpretación de las referencias de V4.32.0j: el escudo
normal debe acompañar a su mano izquierda; la mano derecha y el mango tienen
destinos azules distintos; y el golpe debe recorrer la curva negra antes de
volver en línea recta. No modifica Fire, AltFire, Zoom/Block, Aire,
enfriamiento, durabilidad, sonidos, persistencia, equipo, HUD, mapas ni
diálogos. Todo ese comportamiento permanece en las rutas autoritativas de
`CaelumPlayer` ya aprobadas.

## Encuadre por estado

| Estado | Escudo (10) | Mano izquierda (20) | Mano/dedos derechos (25/40) | Espada (30) |
| --- | ---: | ---: | ---: | ---: |
| Reposo | X=82, Y=45 | X=82, Y=45 | X=282, Y=32 | X=280, Y=4 |
| Block sostenido | X=160, Y=100 | X=160, Y=100 | X=160, Y=0 | X=160, Y=0 |

En reposo, escudo y mano izquierda comparten X=82, Y=45; así ambos llegan a la
marca azul inferior izquierda. A la derecha, palma y dedos quedan en (282,32),
mientras la hoja usa (280,4). Esta separación registrada corrige el mango que
V4.32.0j dejaba demasiado abajo: respecto de aquella prueba, la mano se mueve
6 unidades a la izquierda y 4 hacia abajo, y la espada 8 a la izquierda y 24
hacia arriba.

## Block frontal, cercano y sostenido

H sigue siendo la transición breve de tres tics. I usa duración `-1` y queda
fijo hasta que termine el estado real de Block; no existe un ciclo H/I. El
arte del escudo y su escala permanecen byte por byte iguales a V4.32.0i. Sus
offsets de Block también permanecen en (160,100); sólo cambia su pose normal.

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
rotación del motor. V4.32.0k conserva los extremos absolutos aprobados y agrega
interpolaciones para que el cambio acompañe todo el recorrido:

| Momento | Rotación del motor | Ángulo visual aproximado |
| --- | ---: | ---: |
| Reposo | 18° | 79° |
| Salida 1 | 21° | 82° |
| Ápice | 24° | 85° |
| Barrido 1 | 31° | 92° |
| Barrido 2 | 38° | 99° |
| Impacto | 43° | 104° |
| Retorno 1 | 39° | 100° |
| Retorno 2 | 31° | 92° |
| Retorno 3 | 24° | 85° |
| Reposo recuperado | 18° | 79° |

Así el reposo queda dentro del intervalo 75–80° indicado por el autor y el
golpe cruza ligeramente la vertical dentro del intervalo 95–110°. Cada valor
es absoluto, no acumulativo, y se reaplica durante la sincronización.

## Curva de ataque y retorno recto

Los ocho tics continúan reutilizando la pose A: no regresan los cuadros E/F/G
ni el movimiento de volcar la espada. Cinco puntos llevan la mano desde reposo
por la curva negra hasta el impacto. Los tres puntos posteriores están
colineales con impacto y reposo, por lo que la mano vuelve directamente.

| Tic | Fase | Mano/dedos X,Y | Espada X,Y | Rotación |
| ---: | --- | ---: | ---: | ---: |
| 1 | Salida | (300,15) | (298,-13) | 21° |
| 2 | Ápice derecho | (318,-4) | (316,-32) | 24° |
| 3 | Barrido alto | (287,-1) | (285,-29) | 31° |
| 4 | Aproximación | (236,11) | (234,-17) | 38° |
| 5 | Impacto izquierdo | (201,21) | (199,-7) | 43° |
| 6 | Retorno 1 | (228,25) | (226,-3) | 39° |
| 7 | Retorno 2 | (255,28) | (253,0) | 31° |
| 8 | Retorno 3 | (275,31) | (273,3) | 24° |
| — | Reposo | (282,32) | (280,4) | 18° |

En la referencia 1920×1080, el anclaje de la mano pasa aproximadamente por el
ápice (1739,610), llega al impacto (1212,745) y vuelve a (1577,805). La
diferencia constante de la espada respecto de palma/dedos es (-2,-28), de modo
que el mango permanece en su marca azul durante todo el recorrido.

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
visual dentro de GZDoom 4.14.2 queda pendiente con `PRUEBAS_4_32_0k.txt`; no es
necesario repetir los sistemas no visuales ya aprobados.

# Corrección de capas y agarre — Domingo FP V4.32.0l

> **Superada por V4.32.0m.** V4.32.0l ocultó la mano equivocada durante Block.
> La revisión vigente restaura `LHND` junto al escudo y oculta el conjunto
> derecho `RHND`/`DSWD`/`RFNG`.

## Mano única durante Block

La captura de validación de V4.32.0k mostró dos manos simultáneas bajo el
escudo sostenido. La mano situada en el borde inferior izquierdo correspondía
a la capa 20 (`LHND`); era redundante con el conjunto de agarre ya visible en
las capas 25/30/40.

Al entrar en Block, V4.32.0l limpia explícitamente la capa 20 tanto desde la
transición normal como desde la sincronización por cambio de equipo. El estado
`CA_SwordLeftBlock` se elimina para impedir que esa mano vuelva a iniciarse por
accidente. Al soltar Block, `A_CaelumSwordStartIdleView` restaura la mano
izquierda normal si todavía existe un escudo válido.

No cambian el escudo `DSHD`, su encuadre (160,100), su tamaño, su perspectiva,
la duración H(3)→I(-1), ni la mano restante de Block.

## Espada cuatro unidades a la izquierda

La palma y los dedos conservan todos los puntos aprobados en V4.32.0k. Sólo la
capa 30 (`DSWD`) se desplaza cuatro unidades lógicas hacia la izquierda en
reposo y en cada uno de los ocho tics del ataque:

| Fase | Mano/dedos | Espada V4.32.0l | Rotación |
| --- | ---: | ---: | ---: |
| Reposo | (282,32) | (276,4) | 18° |
| Salida | (300,15) | (294,-13) | 21° |
| Ápice | (318,-4) | (312,-32) | 24° |
| Barrido alto | (287,-1) | (281,-29) | 31° |
| Aproximación | (236,11) | (230,-17) | 38° |
| Impacto | (201,21) | (195,-7) | 43° |
| Retorno 1 | (228,25) | (222,-3) | 39° |
| Retorno 2 | (255,28) | (249,0) | 31° |
| Retorno 3 | (275,31) | (269,3) | 24° |

La diferencia queda constante en (-6,-28), por lo que no cambia la forma de
la curva, el retorno recto, el ángulo ni el ritmo. El único resultado buscado
es que el mango penetre un poco más bajo la capa frontal `RFNG` y quede tapado
por los dedos.

## Alcance congelado

Los sprites y sus chunks `grAb` son byte por byte iguales a V4.32.0k. Tampoco
cambian daño, Aire, bloqueo real, durabilidad, equipo, HUD, mapas, persistencia,
Palomo, Caja Mágica, economía, comercio, crafting ni diálogos.

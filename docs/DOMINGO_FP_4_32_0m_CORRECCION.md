# Corrección de mano y desplazamiento — Domingo FP V4.32.0m

> Estado histórico: V4.32.0n conserva esta corrección de Block y el registro
> horizontal, pero reemplaza la altura de reposo, la cobertura del pulgar y la
> sincronización angular del conjunto derecho.

## Mano correcta durante Block

La captura de V4.32.0l confirmó que aquella revisión ocultó la mano equivocada.
La composición correcta conserva las dos capas pertenecientes al escudo:

- capa 10, `DSHD`: reverso del escudo;
- capa 20, `LHND`: mano situada en el borde inferior izquierdo.

Ambas ejecutan H durante tres tics y sostienen I con duración `-1` en
(160,100). La mano sobrante era el conjunto de la mano hábil situado debajo del
lado derecho del escudo. Por eso V4.32.0m limpia al entrar en Block:

- capa 25, `RHND`;
- capa 30, `DSWD`;
- capa 40, `RFNG`.

La limpieza se aplica tanto en la entrada normal como en la resincronización
por cambio de equipo. Al soltar Block, el estado de reposo reconstruye esas
tres capas. El código elimina sus antiguos estados H/I de Block para que el
conjunto derecho no pueda reaparecer accidentalmente.

## Segundo desplazamiento de la espada

V4.32.0l desplazó la hoja 4 unidades lógicas a la izquierda. V4.32.0m agrega
otras 16 unidades en la misma dirección, exactamente cuatro veces el ajuste
anterior. El desplazamiento acumulado respecto de V4.32.0k es de 20 unidades.

| Fase | Mano/dedos | Espada V4.32.0m | Rotación |
| --- | ---: | ---: | ---: |
| Reposo | (282,32) | (260,4) | 18° |
| Salida | (300,15) | (278,-13) | 21° |
| Ápice | (318,-4) | (296,-32) | 24° |
| Barrido alto | (287,-1) | (265,-29) | 31° |
| Aproximación | (236,11) | (214,-17) | 38° |
| Impacto | (201,21) | (179,-7) | 43° |
| Retorno 1 | (228,25) | (206,-3) | 39° |
| Retorno 2 | (255,28) | (233,0) | 31° |
| Retorno 3 | (275,31) | (253,3) | 24° |

La relación espada–mano queda constante en (-22,-28). No se mueve la palma ni
la capa frontal de dedos; tampoco cambian la curva, el regreso recto, los
ángulos o la duración de ocho tics.

## Alcance congelado

Todos los sprites y sus chunks `grAb` son byte por byte iguales a V4.32.0l.
No cambian daño, Aire, defensa, cobertura, durabilidad, equipo, HUD, mapas,
persistencia, Palomo, Caja Mágica, economía, comercio, crafting ni diálogos.

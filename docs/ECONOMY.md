# Caelum Argenteum — Economía y primer comerciante V4.32.0b

V4.32.0a-r4 conserva sin cambios todos los valores y fórmulas de r3. Su única
corrección funcional declara en `play scope` los helpers que inspeccionan
instancias vivas de inventario, requisito de GZDoom 4.14.2 durante `LoadActors`.
La matriz acumulativa de pruebas fue completada y aprobada por el autor. Sobre
esa base, V4.32.0b conecta a Palomo como primer comerciante bilateral sin
alterar ningún valor de materiales, recetas o monedas.

## 1. Unidad monetaria

La unidad contable es el **cobre monetario**. Todas las cantidades económicas
internas se expresan primero en equivalentes de cobre. Una unidad monetaria de
plata equivale a 200 cobres y una unidad monetaria de oro equivale a 200
platas, es decir, 40.000 cobres.

Cada metal tiene monedas nominales de 1, 5, 20, 50 y 100:

| Metal | Denominación | Valor en cobre | Peso por moneda |
| --- | ---: | ---: | ---: |
| Cobre | 1 | 1 | 0,001 kg |
| Cobre | 5 | 5 | 0,001 kg |
| Cobre | 20 | 20 | 0,001 kg |
| Cobre | 50 | 50 | 0,001 kg |
| Cobre | 100 | 100 | 0,001 kg |
| Plata | 1 | 200 | 0,001 kg |
| Plata | 5 | 1.000 | 0,001 kg |
| Plata | 20 | 4.000 | 0,001 kg |
| Plata | 50 | 10.000 | 0,001 kg |
| Plata | 100 | 20.000 | 0,001 kg |
| Oro | 1 | 40.000 | 0,001 kg |
| Oro | 5 | 200.000 | 0,001 kg |
| Oro | 20 | 800.000 | 0,001 kg |
| Oro | 50 | 2.000.000 | 0,001 kg |
| Oro | 100 | 4.000.000 | 0,001 kg |

Las monedas son objetos físicos apilables de `Actor.Inv`. Persisten en
guardados y viajes, pueden recogerse y soltarse, y obedecen las mismas reglas
de carga y Caja Mágica que los demás objetos. El total visible del Diario suma
todas las monedas poseídas, incluidas las guardadas en la Caja Mágica. Las que
están fuera aportan su peso completo; las guardadas entran en el peso real total
que la caja divide por sus slots máximos y trunca a 0,001 kg.

Son objetos monetarios nominales: el jugador no puede fundirlos ni acuñarlos y
su valor facial no se deriva del valor de la plata u oro usados como materiales.

Clases nativas:

- Cobre: `CaelumCopperCoin`, `CaelumCopperCoin5`,
  `CaelumCopperCoin20`, `CaelumCopperCoin50`, `CaelumCopperCoin100`.
- Plata: `CaelumSilverCoin`, `CaelumSilverCoin5`,
  `CaelumSilverCoin20`, `CaelumSilverCoin50`, `CaelumSilverCoin100`.
- Oro: `CaelumGoldCoin`, `CaelumGoldCoin5`, `CaelumGoldCoin20`,
  `CaelumGoldCoin50`, `CaelumGoldCoin100`.

## 2. Valores base de materias primas y consumibles

Los precios siguientes son anclas de diseño autorizadas. La dureza y la
abundancia aceptadas en V4.31 continúan determinando cuánto cuesta obtener un
recurso en tiempo y esfuerzo, pero ya no recalculan automáticamente su valor
monetario.

| Materia prima | Cobres por unidad de 0,001 kg |
| --- | ---: |
| Madera común | 2 |
| Fibra vegetal | 3 |
| Piel de vaca | 3 |
| Carbón mineral | 5 |
| Cobre bruto | 5 |
| Estaño bruto | 5 |
| Hierro bruto | 7 |
| Plata bruta | 100 |
| Ópalo bruto | 500 |
| Topacio bruto | 500 |
| Esmeralda bruta | 500 |
| Zafiro bruto | 500 |
| Rubí bruto | 500 |
| Oro bruto | 1.000 |

Lana, algodón, seda bruta, piel de depredador y piel de monstruo conservan por
ahora sus anclas provisionales anteriores:

| Familia | Grado 1 | Grado 2 | Grado 3 |
| --- | ---: | ---: | ---: |
| Fibra: lana / algodón / seda bruta | 2 | 4 | 8 |
| Piel: vaca / depredador / monstruo | 3 | 4 | 8 |

Cambiar esos valores pendientes requerirá una decisión de diseño explícita; la
abundancia de la fuente no los sobrescribirá sola.

Los siguientes valores corresponden a una unidad completa del objeto
consumible, no a un gramo de contenido:

| Consumible | Valor base en cobre |
| --- | ---: |
| Ración de comida | 4 |
| Ración de agua | 6 |

## 3. Valor recursivo de manufactura

El sistema calcula el valor con las recetas reales y siempre toma como
referencia la **eficiencia material de 100 %**. Las eficiencias jugables de
25/50/100 % y sus tiempos 1×/10×/100× permanecen intactos; la merma elegida por
el jugador no redefine el precio base del objeto.

### 3.1 Procesamiento básico

Para lingotes, aleaciones, tejido, cuerda y cuero:

```text
valor unitario de salida =
    suma(valor unitario de cada insumo × unidades requeridas)
    × 1,25
    / unidades de salida al 100 %
```

El recargo de esta etapa es siempre **25 %**.

### 3.2 Componentes

Cada componente toma el valor del material **ya procesado** que consume, no el
de su materia prima original. Luego aplica el recargo correspondiente a la red
de estaciones de su tier:

| Tier | Infraestructura acumulativa | Valor agregado |
| --- | --- | ---: |
| T1 | Banco de trabajo + estación principal | 25 % |
| T2 | Red T1 + estación especializada | 50 % |
| T3 | Red T2 + Banco Maestro | 100 % |

Los escudos conservan su requisito adicional de yunque; no cambia el tier ni
duplica el recargo.

### 3.3 Objetos finales

Armas físicas, armas de esencia, armaduras, escudos, amuletos y sellos suman
el valor de sus componentes ya manufacturados, incluidos los detalles de
plata y oro existentes en la receta. Sobre esa suma vuelven a aplicar el
recargo T1/T2/T3 de la tabla anterior. Por lo tanto, cada etapa conserva su
propia mano de obra y el valor se acumula de forma recursiva.

`CaelumEconomyRules` expone el cálculo por material, por familia de objeto y
por instancia nativa de inventario. Las raciones de comida y agua ya poseen
valor base autorizado. Munición, demás consumibles, llaves y objetos clave no
entran todavía al catálogo comercial porque carecen de receta o de un valor
base autorizado; devolverles un precio inventado violaría esta regla.

## 4. Márgenes de comerciante

El margen se aplica una sola vez al total del lote:

```text
NPC compra al jugador = piso(valor base total × 0,50)
NPC vende al jugador  = techo(valor base total × 1,50)
```

El piso al pagar y el techo al cobrar evitan crear cobre por redondeo. Aplicar
el margen después de sumar el lote permite, por ejemplo, que dos unidades de
valor base 1 se vendan juntas por 1 cobre aunque una unidad aislada produzca
una fracción no representable.

Los métodos autoritativos son:

- `CaelumEconomyRules.GetPricePaidByMerchant`
- `CaelumEconomyRules.GetPriceChargedByMerchant`

Personalidades, reputación, regateo y diferencias regionales no modifican
estos valores base en V4.32.0b. Se conectarán después sobre esta única capa
de precios, sin duplicar fórmulas dentro de cada NPC.

## 5. Palomo: catálogo y transacción física

Palomo aparece anclado 64 unidades frente al inicio de MAP01. El primer `Use`
regala la Caja Mágica; una interacción posterior abre el comercio. Compra y
vende los cinco objetos autorizados. Estos valores iniciales de stock y caja
están centralizados para el balance posterior:

| Objeto | Valor base | Palomo cobra por 1 | Palomo paga por 1 | Stock inicial |
| --- | ---: | ---: | ---: | ---: |
| Ración de comida | 4 | 6 | 2 | 20 |
| Ración de agua | 6 | 9 | 3 | 20 |
| Madera | 2 | 3 | 1 | 100 |
| Cobre bruto | 5 | 8 | 2 | 50 |
| Estaño bruto | 5 | 8 | 2 | 50 |

La caja inicial de Palomo contiene **200 cobres**. Stock y dinero son finitos,
se actualizan en ambas direcciones y persisten por personaje. Guardarlos fuera
del actor del mapa permite reubicar a Palomo mediante una futura etapa de
misión sin reiniciarlos y evita que una transacción de un jugador duplique o
consuma el estado autoritativo de otro.

Los lotes disponibles son 1, 5, 20, 50 y 100. El 50%/150% se aplica al valor
base del lote completo y recién después se redondea; por eso cinco unidades de
cobre bruto cuestan 38 cobres y no 40. La interfaz muestra existencias de
Palomo, unidades vendibles del jugador, dinero de ambas partes y total exacto.

La transacción usa las quince monedas físicas. Puede consumir cualquier metal
o denominación, elige la moneda mínima que cubra una diferencia y devuelve
cambio con las denominaciones existentes. Antes de mutar inventario valida en
conjunto dinero, stock, materiales reservados por crafting, carga final y slots
de Caja Mágica. Una operación rechazada no altera dinero ni mercancía.

Controles: Arriba/Abajo selecciona objeto; Izquierda/Derecha alterna comprar o
vender; Espacio/X recorre el tamaño de lote; Enter/A confirma; Q, Tab, Escape o
B cierran. Alejarse más de 160 unidades, viajar o perder a Palomo cierra la
sesión.

## 6. Presentación en inventario

El Diario incorpora un filtro de monedas y, junto a **Carga** y **Caja
Mágica**, muestra:

- valor total expresado en cobres;
- cantidad física total de monedas de cobre, sumando sus cinco denominaciones;
- cantidad física total de monedas de plata, sumando sus cinco denominaciones;
- cantidad física total de monedas de oro, sumando sus cinco denominaciones.

La línea de Caja Mágica muestra además sus slots usados/máximos y su peso total:
10,000 kg propios más la contribución reducida de todo el contenido. La fórmula,
las restricciones y los casos de cambio de Inteligencia están documentados en
`docs/MAGIC_BOX.md`.

Los tres iconos RGBA 64×64 suministrados para Caelum Argenteum se conservan sin
redibujar en `graphics/caelum/icons/currency/`. Las cinco denominaciones de un
mismo metal comparten imagen y se distinguen por su nombre localizado y valor
facial. Las copias registradas como `CCOP`, `CSIL` y `CGOL` permiten también que
cada moneda exista como pickup visible en el mundo.

# V4.30: refinado, componentes, reparación y desarme

**Estado:** especificación de diseño autorizada; no implementada en 4.29.0ar.

Este documento fija las reglas ya decididas para V4.30. El ejecutable de
4.29.0ar conserva sus transacciones inmediatas, su catálogo persistente de 79
recetas y sus herramientas de reparación/desarme de desarrollo. Ningún tiempo,
coste proporcional o receta de componente descrito aquí debe presentarse como
funcional hasta que exista su transacción autoritativa y pase pruebas en
GZDoom.

## 1. Unidades, rendimiento y tiempo

Una unidad de material conserva la precisión existente de `0.001` de peso.
Las cantidades de inventario siguen siendo enteras; la política de redondeo de
los resultados proporcionales queda pendiente.

El refinado y la fabricación de materiales de equipo ofrecen tres eficiencias
sobre una misma entrada base `B`:

| Eficiencia | Salida ideal | Factor de tiempo | Duración de prueba |
|---|---:|---:|---:|
| 50% | `0.50 * B` | x1 | 9 s |
| 75% | `0.75 * B` | x3 | 27 s |
| 100% | `1.00 * B` | x9 | 81 s |

La duración base del entorno de prueba es 9 segundos. Durante la primera
validación se desactiva la contribución de Destreza y la velocidad efectiva es
100%. La fórmula existente que se conectará posteriormente es:

```text
Type1DexterityPercent = 100 + Dexterity * (Dexterity + 1) / 2
EffectiveSeconds = BaseSeconds * EfficiencyTimeFactor
                 * 100 / Type1DexterityPercent
```

No se autoriza todavía un temporizador, reserva de materiales ni regla de
cancelación concreta.

## 2. Materiales de equipo

Cada componente de equipo se fabrica a partir de **un solo tipo de material
base**. La opción rápida parte del 50% de conversión; las opciones de 75% y
100% usan la misma entrada única con los factores temporales anteriores. Esta
restricción no convierte el montaje final de un objeto en una receta de un
solo ingrediente.

### Mapeo autorizado

| Componentes de equipo | Único material base |
|---|---|
| Hojas; puntas; cabezas; placas; cota; cañón; mecanismo; cadena; campana | Lingote del metal correspondiente |
| Empuñadura y empuñadura larga | Madera |
| Asta; armazón; armazón largo; mango; mango largo | Madera |
| Base de bastón y base de estatuilla | Madera |
| Base de libro; cuerda y cuerda reforzada | Fibra vegetal |
| Correa y correa reforzada | Cuero sencillo, siempre tier 1 |
| Material de armadura | Cuero del mismo tier del equipo |
| Esencia de fuego | Rubí bruto |
| Esencia de agua | Zafiro bruto |
| Esencia de tierra | Esmeralda bruta |
| Esencia de viento | Topacio bruto |
| Quintaesencia | Ópalo bruto |
| Colgantes, gemas y broche elemental de joyería | Gema bruta del elemento correspondiente |
| Cadena de plata | Lingote de plata |
| Base de sello | Metal; lingote correspondiente al tier solicitado del componente |

Los metales tiered conservan la progresión de materiales existente: bronce en
tier 1, hierro en tier 2 y acero en tier 3. Un componente estructural que la
receta final solicita expresamente en tier 1 usa su variante más sencilla.

La madera cubre las variantes común, dura y ébano/mágica ya nombradas por la
interfaz. El cuero tier 1/2/3 sigue correspondiendo a vaca,
depredador y monstruo. El tejido tier 1/2/3 ya procesado sigue correspondiendo
a lana, algodón y seda, aunque V4.30 establece cuero —no tejido, cota ni
placa— como material de las dieciséis recetas de armadura.

Las correas de armadura y escudo nunca suben de material: siempre consumen
cuero sencillo. Las distribuciones de peso vigentes no cambian por esta
decisión: cabeza/cuerpo usan 20% correa y 80% material de armadura;
manos/pies usan 60% correa y 40% material de armadura; los escudos usan 30%
correa y 70% placa.

## 3. Catálogo persistente actual de 79 recetas

Los rangos siguientes documentan el orden actual. Son índices persistentes de
base cero; V4.30 no debe renumerarlos al añadir fabricación de componentes.

| Índices | Cantidad | Familia | Ingredientes de montaje actuales / regla V4.30 |
|---:|---:|---|---|
| 0-15 | 16 | Armas físicas y a distancia | Un componente básico tier 1 + un componente que aporta tier; se conservan sus proporciones por peso |
| 16-31 | 16 | Armaduras, 4 tipos x 4 ranuras | V4.30: correa de cuero sencillo + cuero del tier del equipo para los cuatro tipos |
| 32-51 | 20 | Armas elementales, 4 implementos x 5 elementos | 90% base de bastón/campana/libro/estatuilla + 10% esencia elemental |
| 52-55 | 4 | Amuletos | 20% cadena de plata + 80% colgante de la gema asignada |
| 56-60 | 5 | Sellos | 40% base metálica de sello + 60% gema/broche del elemento |
| 61-64 | 4 | Escudos | 30% correa de cuero sencillo + 70% placa de su forma |
| 65-78 | 14 | Procesamiento | Cinco lingotes, bronce, acero, tres tejidos, cuerda y tres cueros |

Las dieciséis armas físicas conservan esta identidad de componentes:

| Arma | Componente de tier | Componente básico tier 1 |
|---|---|---|
| Daga | Hoja pequeña | Empuñadura de madera |
| Hachuela | Cabeza pequeña | Mango de madera |
| Machete | Hoja curva | Mango de madera |
| Jabalina | Punta | Asta de madera |
| Espada | Hoja | Empuñadura de madera |
| Hacha | Cabeza de arma | Mango de madera |
| Mayal | Cabeza redonda | Cadena |
| Lanza | Punta | Asta de madera |
| Mandoble | Hoja larga | Empuñadura larga de madera |
| Hacha de guerra | Hoja ancha | Mango largo de madera |
| Alabarda | Hoja larga | Asta de madera |
| Guanteletes gigantes | Placa grande | Correa reforzada de cuero sencillo |
| Arco | Armazón de madera | Cuerda de fibra |
| Carabina | Cañón | Mecanismo |
| Arco largo | Armazón largo de madera | Cuerda de fibra |
| Ballesta | Armazón de madera | Cuerda reforzada de fibra |

Las catorce transformaciones de procesamiento existentes conservan sus
ingredientes identificables mientras se decide cómo aplicarles las nuevas
eficiencias:

| Salida | Entrada actual |
|---|---|
| Lingotes de cobre, estaño, hierro, plata y oro | 2 unidades del mineral respectivo por 1 lingote |
| Bronce | 9 cobre + 1 estaño por 10 bronce |
| Acero | 497 hierro + 3 carbón por 500 acero |
| Tejido de lana, algodón o seda | 2 unidades de la fibra respectiva por 1 tejido |
| Cuerda | 2 fibras vegetales por 1 cuerda |
| Cuero de vaca, depredador o monstruo | 2 pieles respectivas por 1 cuero |

## 4. Reparación

Reparar usa la receta completa del objeto y exactamente la misma
infraestructura de estaciones que fabricarlo. Para cada ingrediente de receta
`i`, antes del redondeo pendiente:

```text
MissingFraction = (MaximumDurability - CurrentDurability)
                / MaximumDurability
RepairInput[i] = FullRecipeInput[i] * MissingFraction
```

El tier, tamaño, esencia, forma, ranura y acabado del objeto determinan la
misma receta que determinaron su fabricación. Esta regla fija el coste de
materiales; no fija todavía si el tiempo de reparación también se multiplica
por `MissingFraction`.

## 5. Desarme

El desarme devuelve siempre el 50% de los materiales correspondientes a la
receta del objeto, escalado por la durabilidad que todavía conserva:

```text
RemainingFraction = CurrentDurability / MaximumDurability
DismantleOutput[i] = FullRecipeInput[i] * 0.50 * RemainingFraction
```

Un objeto con durabilidad cero devuelve cero; uno intacto devuelve como máximo
la mitad de su receta. Las armas elementales devuelven su base de implemento y
la esencia del elemento correspondiente. No existe elección entre recuperar
una esencia o recuperar el implemento intacto.

## 6. Infraestructura ya existente

La reparación heredará sin cambios la red exigida por la fabricación final:

| Familia | Red de estaciones actual |
|---|---|
| Armas de forja | Banco + Forja; tier 2 añade Yunque; tier 3 añade Banco Maestro |
| Armas a distancia | Banco + Taller de Armas a Distancia; tier 2 añade Aserradero; tier 3 añade Banco Maestro |
| Armadura mágica/ligera | Banco + Taller de Armaduras; tier 2 añade Máquina de Coser; tier 3 añade Banco Maestro |
| Armadura media/pesada | Banco + Forja; tier 2 añade Yunque; tier 3 añade Banco Maestro |
| Escudos | Banco + Forja + Yunque en todo tier; tier 3 añade Banco Maestro |
| Armas elementales | Banco + Altar de Esencias; tier 2 añade Globo; tier 3 añade Banco Maestro |
| Amuletos y sellos | Banco + Banco de Joyero; tier 2 añade Herramientas Finas; tier 3 añade Banco Maestro |
| Metales y aleaciones | Banco + Forja |
| Fibras, tejidos, cuerda y cuero | Banco + Máquina de Coser |

El cambio de ingrediente de las armaduras a cuero no modifica por sí solo la
infraestructura heredada de sus cuatro tipos.

## 7. Decisiones todavía abiertas

Antes de implementar la transacción temporizada faltan únicamente estas
definiciones:

- redondeo de costes y salidas a unidades enteras de `0.001`;
- si el tiempo de un lote escala con x1/x10/x100/x1000 o si 9 segundos son por
  transacción completa;
- aplicación de 50%/75%/100% a las aleaciones de dos entradas sin alterar sus
  proporciones 9:1 y 497:3;
- acciones que cancelan una tarea, momento de consumo/reserva y política de
  devolución al cancelar;
- tiempo del desarme, estaciones exigidas para desarmar y si el tiempo de
  reparación escala con la fracción faltante;
- estaciones y método de aprendizaje para las nuevas recetas de componentes;
- representación persistente de madera dura y ébano/mágica, ya que el catálogo
  actual solo tiene un ID base de madera;
- tratamiento proporcional de los metales decorativos de acabados plateado y
  dorado al reparar o desarmar;
- conciliación de la recuperación especial de la jabalina arrojada con la
  fórmula única de desarme;
- inclusión futura de amuletos y sellos, que hoy no participan del ciclo de
  durabilidad de armas, armaduras y escudos.

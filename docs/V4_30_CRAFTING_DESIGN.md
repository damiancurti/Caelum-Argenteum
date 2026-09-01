# V4.30: refinado, componentes, reparación y desarme

**Estado:** especificación de diseño autorizada; no implementada en 4.29.0at.

Este documento fija las reglas ya decididas para V4.30. El ejecutable de
4.29.0at conserva sus transacciones inmediatas, su catálogo persistente de 79
recetas y sus herramientas de reparación/desarme de desarrollo. Ningún tiempo,
coste proporcional o receta de componente descrito aquí debe presentarse como
funcional hasta que exista su transacción autoritativa y pase pruebas en
GZDoom.

## 1. Unidades, rendimiento y tiempo

Una unidad entera de inventario representa `0.001` de peso. Todo coste exacto
que produzca una fracción de esa unidad se redondea **hacia arriba**; toda
salida o devolución se redondea **hacia abajo**:

```text
InputUnits  = Ceil(ExactInput / 0.001)
OutputUnits = Floor(ExactOutput / 0.001)
```

El redondeo se aplica por material después de calcular la receta, su
eficiencia y la fracción de durabilidad. Así ninguna tarea resulta gratuita
por un coste fraccionario y el jugador nunca recibe más material que la salida
teórica.

El refinado y la fabricación de materiales de equipo ofrecen tres eficiencias
sobre una misma entrada base `B`:

| Eficiencia | Salida ideal | Factor de tiempo | Duración de prueba |
|---|---:|---:|---:|
| 50% | `0.50 * B` | x1 | 9 s |
| 75% | `0.75 * B` | x3 | 27 s |
| 100% | `1.00 * B` | x9 | 81 s |

La duración base del entorno de prueba es 9 segundos por **transacción
completa**, con independencia de que el lote use el multiplicador de cantidad
x1, x10, x100 o x1000. Durante la primera validación se desactiva la
contribución de Destreza y la velocidad efectiva es 100%. La fórmula existente
que se conectará posteriormente es:

```text
Type1DexterityPercent = 100 + Dexterity * (Dexterity + 1) / 2
EffectiveSeconds = BaseSeconds * EfficiencyTimeFactor
                 * 100 / Type1DexterityPercent
```

Una tarea no puede iniciarse mientras el personaje está en combate. Una vez
iniciada, sólo se cancela mediante una orden explícita del usuario: recibir
daño, moverse o entrar posteriormente en combate no son canceladores
automáticos. Al cancelar no se consume ninguna entrada ni se genera salida.
La finalización sí deberá consumir entradas y generar salidas como una única
transacción atómica. Falta confirmar únicamente si las entradas quedan
reservadas —bloqueadas contra otros usos, pero todavía sin consumirse— durante
el temporizador.

Las aleaciones mantienen sus proporciones de entrada exactas. Bronce siempre
usa cobre/estaño `9:1` y acero siempre usa hierro/carbón `497:3`; la eficiencia
50%/75%/100% se aplica a la salida teórica del lote completo, nunca a cada
entrada por separado ni alterando esas proporciones.

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

La madera tendrá tres identidades persistentes de tier: madera dura en tier 1,
ébano en tier 2 y madera mágica en tier 3. El cuero tier 1/2/3 sigue
correspondiendo a vaca,
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
ingredientes identificables y reciben las nuevas eficiencias. Las aleaciones
de dos entradas aplican la regla proporcional exacta de la sección 1:

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
`i`, antes de aplicar el redondeo de la sección 1:

```text
MissingFraction = (MaximumDurability - CurrentDurability)
                / MaximumDurability
RepairInput[i] = FullRecipeInput[i] * MissingFraction
```

El tier, tamaño, esencia, forma, ranura y acabado del objeto determinan la
misma receta que determinaron su fabricación. Los metales decorativos de un
acabado plateado o dorado participan en el coste con la misma proporción de
durabilidad faltante que todos los demás ingredientes.

El tiempo de reparación también escala con la fracción faltante:

```text
RepairSeconds = FullRecipeSeconds * MissingFraction
```

La reparación exige exactamente la misma infraestructura acumulativa que la
fabricación del objeto. Cada coste fraccionario se redondea hacia arriba según
la sección 1.

## 5. Desarme

El desarme devuelve siempre el 50% de los materiales correspondientes a la
receta del objeto, escalado por la durabilidad que todavía conserva:

```text
RemainingFraction = CurrentDurability / MaximumDurability
DismantleOutput[i] = FullRecipeInput[i] * 0.50 * RemainingFraction
```

Un objeto con durabilidad cero devuelve cero; uno intacto devuelve como máximo
la mitad de su receta. Cada devolución fraccionaria se redondea hacia abajo.
Los metales decorativos de acabados plateado y dorado se recuperan con la misma
fórmula proporcional. Las armas elementales devuelven su base de implemento y
la esencia del elemento correspondiente. No existe elección entre recuperar
una esencia o recuperar el implemento intacto.

La jabalina no constituye una excepción de fabricación, reparación o desarme:
en esas tres operaciones usa las mismas fórmulas que el resto de las armas. Su
recuperación parcial al arrojarla pertenece exclusivamente a la mecánica de
proyectil arrojadizo y no se combina con una transacción de desarme.

Desarmar exige exactamente la misma red acumulativa de estaciones y el mismo
tiempo base que fabricar el objeto correspondiente. No introduce una estación
ni una duración propia.

Amuletos y sellos quedan fuera del ciclo de durabilidad. No se gastan, no se
reparan y no se desarman mediante este sistema.

## 6. Infraestructura ya existente

La reparación y el desarme heredan sin cambios la red exigida por la
fabricación final. Cada receta de componente exige la misma red acumulativa de
estaciones que la receta final del arma o equipo para el que se fabrica:

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

Las recetas nuevas de componentes se aprenden mediante cartas de Tarot de
arcanos menores. La carta concreta asociada a cada receta se definirá
únicamente cuando se implemente el sistema de cartas. V4.30 debe conservar el
punto de integración sin inventar esa correspondencia.

## 7. Única decisión transaccional todavía abierta

Antes de implementar la transacción temporizada falta confirmar si las
entradas quedan reservadas contra otros usos durante la tarea. El momento de
consumo ya está fijado en la finalización atómica y cancelar por orden del
usuario sigue liberando la tarea sin gasto ni salida. La correspondencia exacta
entre recetas y cartas no es una decisión pendiente de esta transacción: queda
deliberadamente aplazada hasta la implementación del sistema de Tarot.

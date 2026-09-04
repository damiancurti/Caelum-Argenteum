# V4.30: refinado, componentes, reparación y desarme

**Estado:** régimen por material y eficiencia por ramas implementado en el
candidato acumulativo 4.30.0i; auditorías de fórmulas y fuente verificadas y
validación manual del autor aprobada en Windows/Doom II. V4.30.0j sólo añade
recursos de audio y no altera este contrato.

Este documento fija las reglas introducidas en V4.30.0b y actualizadas en
V4.30.0i. El catálogo conserva los 79 índices anteriores y anexa 50 recetas de
componentes, para un total persistente de 129. MAP01 y sus materiales de prueba
no cambian por el régimen temporal de 4.30.0i.

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

Todos los procesos ofrecen 25%, 50% y 100% de eficiencia. En refinado y
fabricación aislada de componentes, una entrada base `B` mantiene su coste y
produce `B * Eficiencia`. En montaje de objetos indivisibles, fabricación
directa por capas y reparación, el resultado queda completo y la eficiencia
representa merma: cada entrada teórica `R` consume
`Ceil(R * 100 / Eficiencia)`. Por tanto, 25% usa el cuádruple, 50% usa el doble
y 100% usa la cantidad teórica. El tiempo siempre cuenta todas las unidades realmente
empleadas.

Al fabricar un arma, cada operación del árbol —montaje final, componente o
refinado— conserva una elección independiente. Cambiar la eficiencia de una
capa recalcula sus entradas, todas sus dependencias y las dos vistas previas
sin modificar las demás elecciones. El factor temporal de esa capa abarca la
operación y toda subrama que obliga a fabricar; los factores elegidos en capas
anidadas se acumulan.

Cada unidad de material empleada cuesta una cantidad de tics determinada por
la complejidad de la operación:

| Complejidad | Tics por unidad | Operaciones actuales |
|---|---:|---|
| Sencilla | 1 | Refinado común, componentes estructurales y armas físicas de filo o asta |
| Normal | 2 | Arco, arco largo y mayal |
| Detallada | 3 | Armaduras, escudos, guanteletes gigantes y ballesta |
| Delicada/compleja | 4 | Esencias, refinado de gemas, componentes de joyería, armas elementales, sellos, amuletos y carabina |

Cada eficiencia añade además un factor de trabajo independiente:

| Eficiencia | Factor temporal |
|---:|---:|
| 25% | 1× |
| 50% | 10× |
| 100% | 100× |

El factor se aplica después de resolver las unidades realmente empleadas. Por
ejemplo, una entrada teórica de 100 unidades consume 400/200/100 y aporta
400/2.000/10.000 unidades de trabajo propio respectivamente antes de Destreza.
En una ruta recursiva, el factor de la capa multiplica además el trabajo de
cada requisito que esa capa hace necesario fabricar.

La duración de una capa y de la tarea completa es:

```text
Type1DexterityPercent = 100 + Dexterity * (Dexterity + 1) / 2
OwnMaterialSeconds = EmployedMaterialUnits * ComplexityTicsPerMaterial
                   / TICRATE * 100 / Type1DexterityPercent
BranchSeconds(node) = EfficiencyTimeFactor(node)
                    * (OwnMaterialSeconds(node)
                       + Sum(BranchSeconds(requiredChild)))
TaskSeconds = BranchSeconds(final operation)
```

`TICRATE` vale 35. Destreza 0 equivale a 100%; Destreza 100 equivale a
5150%, por lo que el trabajo se completa 51,5 veces más rápido. El tamaño del
lote sí modifica el tiempo porque modifica las unidades empleadas.

Una tarea no puede iniciarse mientras el personaje está en combate. Una vez
iniciada, sólo progresa mientras el Diario sigue abierto en la estación, el
jugador permanece dentro de 96 MU, continúa fuera de combate y la red conserva
toda la infraestructura fotografiada al inicio. Cerrar el Diario, alejarse,
perder una estación o entrar en combate **pausa**, pero no cancela. Al iniciar
se calculan todas las entradas y quedan reservadas: permanecen en el inventario,
pero están bloqueadas contra cualquier otro uso incluso durante la pausa. Sólo
una orden explícita cancela, libera la reserva completa y no produce salida. Al
completar, las entradas reservadas se consumen y las salidas se generan como
una única transacción atómica.

Los refinados comunes y componentes usan un lote x1 de cuatro unidades, de
modo que el redondeo hacia abajo produce 1/2/4 unidades a 25/50/100 y nunca
una salida nula. Las aleaciones mantienen sus proporciones de entrada exactas. Bronce siempre
usa cobre/estaño `9:1` y acero siempre usa hierro/carbón `497:3`; la eficiencia
25%/50%/100% se aplica a la salida teórica del lote completo, nunca a cada
entrada por separado ni alterando esas proporciones.

## 2. Materiales de equipo

Cada componente de equipo se fabrica a partir de **un solo tipo de material
base**. La fabricación aislada transforma esa entrada con rendimiento
25%/50%/100%; dentro de una ruta directa, la misma elección determina cuánta
entrada se necesita para completar la cantidad exigida por la capa superior.
Esta restricción no convierte el montaje final de un objeto en una receta de
un solo ingrediente.

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

## 3. Catálogo persistente de 129 recetas

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
| 79-128 | 50 | Componentes | Una entrada base por receta; salida 25%/50%/100% y misma red de estaciones que su familia de equipo |

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

### Fabricación directa de armas

Una receta de arma física o elemental puede iniciarse aunque falten sus
componentes intermedios, siempre que el personaje posea materiales primarios
suficientes, conozca todas las recetas intermedias necesarias y esté atendiendo
una red que reúna la infraestructura completa de cada paso. El planificador:

1. Consume primero componentes o materiales procesados que ya existan.
2. Resuelve recursivamente sólo lo que falta hasta llegar a materias primas.
3. Reserva de una vez la ruta primaria completa, sin crear lingotes ni
   componentes temporales en el inventario.
4. Aplica a cada paso omitido su propia eficiencia y su propia complejidad.
5. Suma el tiempo por unidad de material sólo de los pasos que realmente debe
   ejecutar y aplica los factores acumulados de sus capas padre, además del
   montaje final.

El Diario presenta a la vez el tiempo de la **ruta actual**, que aprovecha lo
que ya existe en Inventario, y el tiempo teórico **desde materias primas**. La
receta desplegada incluye el montaje final, cada receta intermedia y las
materias primas terminales; las flechas Arriba/Abajo recorren sólo las capas
que permiten elegir eficiencia. Las proporciones exactas de bronce y acero
siguen siendo obligatorias.

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

Después de calcular la fracción faltante, cada entrada aplica la eficiencia
elegida como merma. El tiempo usa exactamente las unidades reservadas y la
complejidad del objeto:

```text
RepairInputWithWaste[i] = Ceil(RepairInput[i] * 100 / EfficiencyPercent)
RepairSeconds = Sum(RepairInputWithWaste)
              * ItemComplexityTics / TICRATE
              * EfficiencyTimeFactor
              * 100 / Type1DexterityPercent
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

Desarmar exige exactamente la misma red acumulativa de estaciones y usa la
complejidad del objeto correspondiente. Su duración cuenta las unidades de la
receta completa antes de la recuperación por durabilidad; no introduce una
estación ni una categoría temporal propia.

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

## 7. Estado de las decisiones

Las reglas transaccionales necesarias para V4.30 están cerradas. La base
atómica se implementó en 4.30.0b y el tiempo por material, el árbol recursivo y
la eficiencia independiente por capa se implementaron en 4.30.0e. El factor
temporal 1×/10×/100× quedó fijado en 4.30.0f. V4.30.0h cambia las opciones
materiales a 25/50/100 sin alterar esos factores. V4.30.0i cierra la inversión
que aún podía aparecer en árboles profundos: cada factor alcanza toda la rama
requerida por su capa y se acumula con los factores de sus subcapas.
Las entradas quedan reservadas contra otros usos durante la tarea, se consumen
sólo al completar y se liberan íntegramente al cancelar. La correspondencia
exacta entre recetas y cartas no es una decisión pendiente de esta transacción:
queda deliberadamente aplazada hasta la implementación del sistema de Tarot.

## 8. Contrato de prueba de 4.30.0h/4.30.0i

MAP01 contiene seis cúmulos interiores con una pila de 10.000 unidades por
cada ID de material. También incluye los tiers 1/2/3 de madera y de las cinco
gemas brutas, que no tienen una transformación anterior capaz de generarlos.
Son 91 pilas y 910.000 unidades de prueba en total. MAP01 conserva esas pilas y
el plano aceptado, pero convierte sus 31 paneles finos restantes en 19 muros
sólidos de 8 MU limitados a z=0..128. Puertas, escaleras, la ocupación/perfil de
los pisos superiores y MAP02 permanecen sin cambios.

Las recetas de componentes empiezan bloqueadas porque sus cartas concretas
aún no están definidas. Para probarlas sin inventar cartas:

```text
ca_debug_crafting_learn_all_recipes
```

Controles dentro de la red de estaciones:

| Entrada | Función |
|---|---|
| `Tab` | Cambiar familia de recetas |
| `Izquierda/Derecha` | Cambiar receta |
| `Espacio` | Tier; en procesamiento cambia el lote |
| `B` | Lote x1/x10/x100/x1000 en procesamiento/componentes |
| `R` | Talle |
| `Arriba/Abajo` | Elegir una capa fabricable de la receta desplegada |
| `X` | Eficiencia 25%/50%/100% de la capa elegida |
| `E` o `Enter` | Iniciar la tarea seleccionada |
| `C` | Cancelar explícitamente la tarea activa |
| `F` | Reparar la pieza exacta seleccionada en el Journal |
| `D` | Desarmar la pieza exacta seleccionada en el Journal |
| `T` | Depuración: adelantar 600 segundos de una tarea válida atendida |

Para reparar o desarmar, se selecciona primero una pieza sin equipar en
Inventario y luego se usa la red de estaciones requerida. La estación abre
directamente Diario → Oficios; el objeto seleccionado se conserva. El Diario
marca con `[R:n]` las unidades reservadas y con `[R:1]` el objeto bloqueado.
Cerrar el Diario, alejarse, perder infraestructura o entrar en combate pausa el
contador y mantiene la reserva. Volver a una red válida permite continuar;
sólo `C` o `ca_crafting_cancel_task` cancela y libera lo bloqueado.

El control de depuración también está disponible como
`ca_debug_advance_crafting_time` y en la sección Caelum Argenteum de Controles.
Respeta la misma sesión, estación, distancia, infraestructura y pausa que el
contador normal; completa atómicamente si los 600 segundos agotan el tiempo.

La matriz enfocada debe comprobar además:

1. Que no aparezca ninguna clave `CA_*` sin localizar en Inventario u Oficios.
2. Que 25%, 50% y 100% cambien materiales y vista previa sin alterar las
   elecciones de otras capas, y que sus factores temporales sean exactamente
   1×, 10× y 100× antes de Destreza y abarquen toda su rama requerida.
3. Que los lotes x1/x10/x100/x1000 escalen el tiempo por las unidades de
   material realmente empleadas.
4. Que una ruta directa desde materias primas muestre componentes y materias
   primas, reserve sus entradas y sume el tiempo de cada paso ejecutado.
5. Que Destreza 0 produzca 100% y Destreza 100 produzca 5150%/51,5×.
6. Que `T` reste exactamente 600 segundos y no avance una tarea pausada o sin
   estación válida.
7. Que la vista previa corresponda al material u objeto seleccionado.
8. Que Izquierda/Derecha/F recorran los filtros y que Derecha desde el último
   pase a Personaje.
9. Que el 2 recorra todas las instancias pequeñas equipadas por `ItemId`, sin
   Pistol ni Clip iniciales.
10. Que los muros convertidos sean sólidos y gruesos desde ambos lados sin
   modificar los pisos superiores.

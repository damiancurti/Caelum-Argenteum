# Caelum Argenteum — Sistemas y reglas vigentes

Versión documental: 4.33.0l — 2026-09-10.

Esta referencia consolida reglas implementadas. El alcance narrativo está en
[MAP01.txt](MAP01.txt), el estado de aceptación en [PROJECT.md](PROJECT.md) y
las variantes históricas en [HISTORY.md](HISTORY.md).

## Prueba de Caella (4.33.0i)

Se habilita al cerrar Argento en fase 35. Fire/AltFire usan sus lanzamientos
reales; User2 conserva Channel del Sello con gasto de Adrenalina. La indicación
antigua Reload/Channel de MAP01 queda sustituida por User2. El Ánima se gasta
al completar un lanzamiento y su recuperación se observa en la reserva real.

La práctica exige cinco hechos y después cuatro runas; el Diario cuenta 0/9
hasta 9/9. Usar sobre una runa con un implemento activo conduce su elemento.
Tierra → Aire → Fuego → Agua abre la entrada existente, devuelve los préstamos
y avanza a fase 45. Error: sólo reinicia las runas; pistas a los 2 y 4 errores.

Las dos instancias temporales reutilizan T1 del catálogo. Conservan ItemId y
la marca CA_ITEMFLAG_LIMBO_TEMP; no se venden, sueltan, desarman ni almacenan
en la Caja. No hay duplicación al preparar otra vez. Para enseñar Channel sin
atacar a nadie, el primer User2 puede completar la reserva hasta un segundo de
su coste nativo, limitada por MaximumAdrenaline. La ayuda termina al registrar
consumo real. Los cooldowns, el combate general y los atributos no cambian.

La persistencia añade índice de secuencia, errores, referencia de Ánima y IDs
del equipo previo; usa flags libres 57–58. No desplaza campos/índices aceptados.
La colocación, compatibilidad, pruebas y límites están en PROJECT.md.

## Ronnie: elección, materiales y primera arma (4.33.0l)

Tras Caella, Ronnie ofrece 36 elecciones T1: 16 armas físicas y cuatro formas
mágicas por cinco esencias. La clase no restringe la elección. Se puede leer y
volver antes de confirmar; confirmar fija la opción y el talle del personaje.
Se aprenden la receta final y todos sus pasos de procesamiento/componentes.
Las cantidades se calculan mediante CaelumCraftingRules; no hay otra tabla
de recetas dentro de la misión. El plan de referencia usa 25% en cada capa.

| Armas | Materias primas del catálogo T1 |
| --- | --- |
| Daga, hachuela, machete, jabalina, espada, hacha, lanza, espadón, hacha de guerra, alabarda | Madera, cobre bruto y estaño bruto. |
| Mangual y carabina | Cobre bruto y estaño bruto. |
| Puños gigantes | Cobre bruto, estaño bruto y cuero de vaca ya curtido. |
| Arco común, arco largo y ballesta | Madera y fibra vegetal. |
| Bastón y estatuilla | Madera y gema bruta de la esencia elegida. |
| Campana | Cobre bruto, estaño bruto y gema bruta. |
| Libro | Fibra vegetal y gema bruta. |

Gemas: rubí/Fuego, zafiro/Agua, esmeralda/Tierra, topacio/Aire y ópalo/Quintaesencia.
El cofre contiene las cinco y cuero T1; no entrega piel cruda para curtir.
Su stock por material es el máximo entre las 36 recetas al talle del jugador,
con eficiencia mínima en cada transformación; no suma 36 armas.
Ejemplo talle M: 12.800 unidades de cada gema y 96.000 de cuero. Una unidad
pesa 0,001 kg. Son límites de stock; se retira sólo lo que requiere la elección
y cabe en la carga actual. No es necesario llevar el contenido completo.

El stock pertenece al registro del personaje. Reabrir/cargar no lo repone.
Devolver retorna sólo cantidades retiradas de ese cofre que siguen sin gastar
y no están reservadas por una tarea. Cancelar libera reservas; cerrar la
estación pausa el trabajo. Se pueden procesar materiales por etapas o elegir
una eficiencia mayor para reducir necesidades. Los faltantes del Diario
descuentan también componentes y procesados que ya posee el jugador.

Tres arbustos 2D de la cueva usan la extracción vegetal existente: daño
cortante produce fibra; perforante/contundente no. Conservan dureza 2,5 y
regeneración general; capacidad 100 kg cada uno. La espada T1 prestada usa
principal cortante y secundario perforante para las vetas de cobre/estaño.
Si ya existe la antigua espada de cueva en inventario, se adopta su ItemId.
Revisarla restaura/equipa la misma pieza. Caella devuelve sólo sus préstamos.

La primera fabricación T1 dentro de esta prueba entrega una instancia personal
con CA_ITEMFLAG_LIMBO_PRESERVABLE. No requiere Caja Mágica, conserva sus
eficiencias y pasa a fase 60. El préstamo se devuelve al hablar con Ronnie.
Antes de salir del Limbo el arma inicial no se vende, descarta ni desarma.
Las armas fabricadas después son temporales y no reemplazan su ItemId.
Fuera de MAP01 se quitan esas instancias y cantidades de materiales de misión;
se preservan materiales propios anteriores aunque compartan pila. Al salir,
el arma inicial puede usarse como equipo ordinario. La transferencia narrativa
de fase 100 a la Caja permanece pendiente.

Las pilas usan LimboQuestUnits y LimboSupplyUnits; consumir descuenta primero
la porción tutorial. El crafting conserva esa procedencia en sus resultados
intermedios y en las reservas al guardar/cargar. No se venden, descartan ni
envían a la Caja pilas con porción tutorial. La salida cancela tareas pendientes
que usaban esos materiales antes de retirarlos. No elimina existencias propias
por coincidencia de nombre ni concede de nuevo un préstamo ya devuelto.

Esta revisión no incorpora munición ni las lecciones pendientes de necesidades,
Aire, agua y reparación. Esas reglas se integran antes del entrenamiento de Rulo.

## Probabilidad social

Rulo usa **Emoción**, derivada de Empatía. Caella usa **Persuasión**, derivada
de Carisma. Ambas usan Tipo 4 y dificultad 120, según la decisión para 0f.
Los residentes no tienen facción asignada: el modificador de reputación es neutro.

```text
capacidad Tipo 4 = 100 + 2 × atributo × (atributo + 1) / 101
probabilidad (%) = limitar(redondear(capacidad × 100 / dificultad), 0, 100)
```

El redondeo es al entero más cercano (`Floor(x + 0.5)`). Para porcentajes de
1 a 99 se tira un entero uniforme de 1 a 100; hay éxito si dado <= porcentaje.
0 falla y 100 tiene éxito automático, sin consumir el generador aleatorio.
La dificultad no es por sí sola un porcentaje: hay que conocer el atributo.

| Dificultad | Atributo 10 | Atributo 30 | Atributo 50 |
| ---: | ---: | ---: | ---: |
| 50 | 100% | 100% | 100% |
| 100 | 100% | 100% | 100% |
| 120 | 85% | 99% | 100% |
| 150 | 68% | 79% | 100% |
| 200 | 51% | 59% | 75% |
| 300 | 34% | 39% | 50% |

Contra dificultad 120: atributo 0 → 83%; 3 → 84%; 10 → 85%; 15 → 87%;
30 → 99%; 31 → 100%. El 31 ya alcanza 100% por redondeo; no requiere que la
capacidad sin redondear llegue exactamente a 120. Una dificultad <= 100 es
automática incluso con atributo cero debido al piso de Tipo 4. Estos datos
explican el balance existente; 0h no cambia la fórmula ni las dificultades.

Ronnie no tira dados. Su opción directa requiere **Labia >= 1**, con:

```text
Labia Tipo 2 = Elocuencia × (Elocuencia + 1) / 101
```

Elocuencia 9 da aproximadamente 0,891 y no alcanza; Elocuencia 10 da 1,089
y habilita la opción. Labia 1 no significa Elocuencia 1.

Los intentos de Rulo/Caella guardan resultado, probabilidad y dado. Reabrir
el diálogo no renueva la tirada. Un fallo habilita el consejo de Argento y una
respuesta alternativa sin azar. Rulo requiere además una respuesta respetuosa:
leer su emoción no equivale a conseguir su colaboración. El consejo también
permite continuar con Ronnie después de visitarlo aunque falte Labia.

## Recursos, persistencia y física

Salud, Ánima, Aire, Adrenalina, Lucidez, Hambre, Sed y Sueño pertenecen al
personaje; los cálculos viven en los módulos de atributos, estadísticas y
recursos. Se conserva la escala **1 hora de juego = 3 minutos reales**.
Los estados y fórmulas no se reequilibran en 0h.

`Actor.Inv` y `CaelumPersistentCharacterState` son las fuentes autoritativas.
El HUD/Diario usa instantáneas, y los tokens USDF son condiciones derivadas.
Exit/changemap transfieren al personaje; `map MAP02` inicia otro personaje.
El progreso cooperativo compartido todavía no está implementado.

Las colisiones usan los módulos de física del proyecto y las restricciones
nativas de movimiento. No convertir las fórmulas de impulso en una segunda
ruta de daño de las armas. Las calibraciones históricas completas se conservan
en HISTORY.md; las pruebas de multitudes permanecen separadas en MAP02.

## Detalle de misiones (4.33.0k–0l)

En Diario → Misiones, F (Y en mando) alterna resumen y Detalle de la misión
visible. Describe de qué trata y qué corresponde hacer en la etapa actual.
Arriba/Abajo recorre el texto; TAB cierra. La navegación es local, no cambia
progreso ni otorga objetos. Las misiones aún desconocidas no aparecen.

Durante Caella enumera primario, secundario, canalización, gasto de Ánima y
recuperación como Hecho/Pendiente. A 5/5 cambia a la secuencia de runas y al
acertijo. A fase 45 indica hablar con Ronnie. La fuente es el registro persistente,
no contadores independientes del menú. La misma indicación de ubicación se
usa en la conversación de Caella y en Detalle para evitar contradicciones.

Ruta: entrada → pasillo central → escalera del fondo. Permanecer en planta
baja, rodearla por la derecha/sur y mirar la pared trasera detrás de ese lado,
cerca del piso. Aceptar la prueba hace aparecer las marcas; práctica 5/5
permite usarlas. Acercarse con bastón activo, apuntar y pulsar Usar. El Sello
de fuego basta; no se dispara para activar las runas.

Durante Ronnie, Detalle muestra el arma elegida, el plan de materias primas
al 25%, las cantidades faltantes y las ubicaciones de cofre, arbustos, vetas y
Banco de Trabajo. Tras fabricar pide devolver la espada; después muestra la
preparación terminada. La lista de misiones indica Arma inicial preparada.

## Presentación del Sello y runas (4.33.0j)

El Sello equipado se ve en el costado derecho del HUD. Conserva sus colores si
User2 puede iniciar la canalización o si ya está canalizando; aparece en escala
de grises si hay recarga, falta Adrenalina o existe otro bloqueo del sistema.
La misma consulta de disponibilidad alimenta la acción y el HUD; observarla
no concede ni consume recursos. La ayuda inicial de Caella cuenta como disponible.

Durante la recarga se muestran debajo los segundos restantes, redondeados
hacia arriba, hasta desaparecer al llegar a cero. La espera conserva los 60 s
existentes. Sin Adrenalina queda gris y sin contador: ese recurso no tiene una
hora garantizada de recuperación. User2 deja de generar el texto central de
estado y el aviso central genérico de habilidad. Los otros controles conservan
su comportamiento.

Caella usa la sección española [es], igual que las conversaciones anteriores.
La práctica exige primario, secundario, canalización, gasto y recuperación de
Ánima. Después, con el implemento mágico activo, Usar activa cada runa. Un solo
Sello y el bastón prestado sirven para Tierra → Aire → Fuego → Agua. El Sello
no determina el elemento de la runa y no se exige dispararle. El progreso y
la devolución del préstamo siguen en el registro persistente existente.

Las estaciones reciben modelos 3D sin modificar su lógica de infraestructura.

## Crafting y reparación

La red de estaciones es acumulativa. Banco de Trabajo y la estación principal
habilitan T1; la especializada añade T2 y Banco Maestro añade T3. Forja usa
Yunque, Distancia usa Aserradero, Armaduras usa Máquina de Coser, Esencias usa
Globo Terráqueo y Joyero usa Herramientas Finas. Los requisitos particulares
de las recetas, incluido el yunque de los escudos, permanecen vigentes.

La eficiencia se elige por capa: 25/50/100% con factores de tiempo 1/10/100.
La merma se propaga por cantidades y cada operación aplica su factor una sola
vez. La regla antigua «todo tarda diez segundos» no describe la fabricación
vigente. Complejidad, unidades, lotes, atributo técnico y subcapas intervienen
en el tiempo. El comercio conserva su tiempo de diez segundos por transacción.

Las tareas reservan materiales y sólo progresan con sesión activa, dentro del
alcance de la estación (96 MU) y con infraestructura disponible. Cerrar o alejarse
pausa; cancelar explícitamente libera las reservas. El armado multicapa permite
partir de recursos primarios. Reparación proporcional y desarme usan la receta
y durabilidad; equipo elemental devuelve sus materiales correspondientes.

## Controles comunes

| Entrada | Función vigente |
| --- | --- |
| Fire | Ataque principal del arma; cancela Block al atacar. |
| AltFire | Ataque secundario del arma; en distancia, Aim alternativo. |
| Reload | Recarga en distancia; carga del próximo ataque cuerpo a cuerpo/mágico. |
| Zoom | Block con arma/escudo compatibles; ADS real en distancia. |
| User1 | Interfaz reservada para habilidad racial; contenido pendiente. |
| User2 | Channel del Sello equipado. |
| User3 | Interfaz de Tarot activo; contenido completo pendiente. |
| User4 | Interfaz de habilidad de clase; contenido pendiente. |
| Use | Interacción nativa con NPC, estaciones, puertas y ascensor. |
| Tab | Diario/Inventario. |

La carga base dura 2 s ajustados por velocidad; la ventana preparada dura 3 s.
El siguiente ataque duplica daño y coste, y las explosiones duplican área
(radio × sqrt(2)). Dolor y cambios incompatibles interrumpen la carga.
La espada usa Fire cortante y AltFire punzante, por lo que sirve para árboles
y vetas del tutorial. No se necesita la hachuela especial retirada en 0d.


## Matriz detallada de armas

Matriz técnica de entradas conservada; la ampliación visual de primera persona
no modifica estas rutas de combate.

### Physical melee weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Dagger | Piercing primary stab. | Stronger slashing attack with shorter range. | Charge next melee attack. | Shield Block. |
| Hatchet | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Machete | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Javelin | Piercing melee thrust. | Throws the javelin; if a valid melee target is close, automatically uses the melee fallback. A real throw costs Air and one durability. | Charge next melee attack. | Shield Block. |
| Sword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Flail | Blunt primary attack. | Stronger blunt attack at the same range. | Charge next melee attack. | Shield Block. |
| Spear | Piercing primary thrust. | No authored secondary attack in the current catalogue. | Charge next melee attack. | Shield Block. |
| Greatsword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | No Block: large/two-handed weapon. |
| War Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | No Block: large/two-handed weapon. |
| Halberd | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | No Block: large/two-handed weapon. |
| Giant Gauntlets | Blunt primary punch. | Same damage, range and Air cost as Fire, with additional upward push. | Charge next melee attack. | Weapon-based Block using Buckler coverage, defense and special rules. |

### Ranged weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Standard Bow | Fires its native arrow from the magazine. | Toggles Aim/ADS. | Reloads the bow magazine; duration uses the ranged reload-speed bonus. | Toggles the same Aim/ADS mode, real FOV and doubled physical accuracy. |
| Longbow | Fires its native longbow arrow. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Crossbow | Fires its native bolt. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Carbine | Fires its native carbine projectile. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |

### Magical implements

Every magical variant below exists at T1, T2 and T3 for Fire/Light, Water/Ice, Earth/Poison, Air/Lightning and Quintessence. `Fire` selects the primary side of the equipped essence and `AltFire` selects its secondary side.

| Implement | Fire and AltFire delivery | Reload | Zoom |
| --- | --- | --- | --- |
| Staff | One normal-speed direct magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Bell | Seven slow projectiles in a broad cone; every projectile rolls its own critical. Uses the confirmed half-damage/double-Anima baseline. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Book | One fast homing magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Statuette | One explosive magical projectile; charged attacks double explosion area. | Charge next magical attack. | Shield Block when a shield is equipped. |

### Essence function used by every magical implement

| Essence | Fire | AltFire |
| --- | --- | --- |
| Fire / Light | Fire damage with Burn damage-over-time. | Light effect with Dazzle control and player illumination. |
| Water / Ice | Water projectile with extreme physical push. | Ice effect with Freeze control. |
| Earth / Poison | Earth effect that reduces target Lucidity. | Poison damage-over-time. |
| Air / Lightning | Air effect with Cut damage-over-time and moderate push. | Lightning Stun control. |
| Quintessence | Double-damage primary projectile. | Independently rolls the available Fire, Light, Water, Earth, Poison, Air and Lightning secondary effects. |

### Complete magical variant list

The following twenty implement/essence combinations each have T1, T2 and T3 selectors, totaling sixty magical weapons:

| Essence | Staff | Bell | Book | Statuette |
| --- | --- | --- | --- | --- |
| Fire / Light | Fire Staff T1–T3 | Fire Bell T1–T3 | Fire Book T1–T3 | Fire Statuette T1–T3 |
| Water / Ice | Water Staff T1–T3 | Water Bell T1–T3 | Water Book T1–T3 | Water Statuette T1–T3 |
| Earth / Poison | Earth Staff T1–T3 | Earth Bell T1–T3 | Earth Book T1–T3 | Earth Statuette T1–T3 |
| Air / Lightning | Air Staff T1–T3 | Air Bell T1–T3 | Air Book T1–T3 | Air Statuette T1–T3 |
| Quintessence | Quintessence Staff T1–T3 | Quintessence Bell T1–T3 | Quintessence Book T1–T3 | Quintessence Statuette T1–T3 |


## Economía

Valores vigentes, conservados desde la base aceptada V4.32.0a-r4.

### 1. Unidad monetaria

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

### 2. Valores base de materias primas y consumibles

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

### 3. Valor recursivo de manufactura

El sistema calcula el valor con las recetas reales y siempre toma como
referencia la **eficiencia material de 100 %**. Las eficiencias jugables de
25/50/100 % y sus tiempos 1×/10×/100× permanecen intactos; la merma elegida por
el jugador no redefine el precio base del objeto.

#### 3.1 Procesamiento básico

Para lingotes, aleaciones, tejido, cuerda y cuero:

```text
valor unitario de salida =
    suma(valor unitario de cada insumo × unidades requeridas)
    × 1,25
    / unidades de salida al 100 %
```

El recargo de esta etapa es siempre **25 %**.

#### 3.2 Componentes

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

#### 3.3 Objetos finales

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

### 4. Márgenes de comerciante

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

Estos son los márgenes normales de la infraestructura comercial. La prueba
posterior de rebaja conserva compra del jugador al 140% y venta al 60%; no
está disponible desde el Palomo canónico de MAP01. Reputación, personalidades
y precios regionales definitivos siguen pendientes de asignación narrativa.

### 5. Presentación en inventario

El Diario incorpora un filtro de monedas y, junto a **Carga** y **Caja
Mágica**, muestra:

- valor total expresado en cobres;
- cantidad física total de monedas de cobre, sumando sus cinco denominaciones;
- cantidad física total de monedas de plata, sumando sus cinco denominaciones;
- cantidad física total de monedas de oro, sumando sus cinco denominaciones.

La línea de Caja Mágica muestra además sus slots usados/máximos y su peso total:
10,000 kg propios más la contribución reducida de todo el contenido. La fórmula,
las restricciones y los casos de cambio de Inteligencia están documentados en
`SYSTEMS.md`.

Los tres iconos RGBA 64×64 suministrados para Caelum Argenteum se conservan sin
redibujar en `graphics/caelum/icons/currency/`. Las cinco denominaciones de un
mismo metal comparten imagen y se distinguen por su nombre localizado y valor
facial. Las copias registradas como `CCOP`, `CSIL` y `CGOL` permiten también que
cada moneda exista como pickup visible en el mundo.

## Caja Mágica

V4.32.0a-r4 sigue siendo la base de peso y almacenamiento aceptada. V4.32.0b
cambia la adquisición: un personaje nuevo ya no posee la Caja Mágica al
comenzar. Las revisiones V4.32 usaron a Palomo para validar el regalo; esa ruta
era un entorno de prueba y V4.33.0b la retira del diálogo canónico. La Caja se
entregará al final de MAP01, después de las cuatro ramas. La prueba anterior
también confirmó que la salida normal conserva la Caja; `map MAP02` crea un
personaje nuevo y no constituye un viaje del personaje.

### 1. Naturaleza y peso propio

La Caja Mágica es una capacidad persistente del personaje una vez recibida. No
existe como objeto seleccionable: no puede soltarse, venderse, destruirse ni
guardarse dentro de sí misma. Antes de recibirla no aporta peso, no ofrece
slots y ninguna ruta de pickup, crafting o interfaz puede guardar objetos en
ella. Al recibirla, su estructura aporta **10,000 kg** a la carga incluso
cuando está vacía.

La cantidad máxima de slots continúa derivándose de Inteligencia. Cada pieza
individual de equipo y cada pila admitida consume un slot, sin importar cuántas
unidades contenga la pila.

### 2. Reducción de peso

El contenido no pierde todo su peso. La carga se calcula con una sola operación
agregada:

```text
peso reducido del contenido =
    piso_a_0,001 kg(peso real total guardado / slots máximos actuales)

peso total de la Caja Mágica =
    10,000 kg + peso reducido del contenido
```

Se usan los **slots máximos**, no los ocupados. Todos los objetos y pilas se
suman antes de dividir y redondear. Esto evita que separar un mismo peso entre
varias pilas elimine carga mediante redondeos individuales.

Ejemplo: con 20 slots máximos y 10,000 kg reales guardados, el contenido aporta
0,500 kg y la caja completa aporta 10,500 kg. Con 0,380 kg guardados, el
contenido aporta 0,019 kg.

### 3. Contenido y restricciones

Se conservan las reglas existentes:

- equipo, consumibles, materiales, monedas, objetos clave admitidos y la pila
  personalizada de munición pueden guardarse;
- las llaves comunes no pueden guardarse, porque GZDoom comprueba su posesión
  nativa para puertas y `LOCKDEFS`;
- flechas y virotes nativos permanecen en el inventario personal;
- una pila completa sigue contando como un único slot, pero todas sus unidades
  aportan al peso real previo a la reducción;
- las monedas guardadas conservan íntegramente su valor y participan del peso
  reducido como cualquier otra pila.

### 4. Transacciones y cambios de capacidad

Recoger, depositar, recuperar, equipar, fabricar y desarmar evalúan la carga
final completa. Una operación se rechaza si, después de retirar el peso de su
ubicación anterior y añadirlo a la nueva, la carga superaría la capacidad del
personaje. Mover un objeto del inventario personal a la caja continúa permitido
cuando libera carga.

Si un cambio de Inteligencia reduce los slots máximos por debajo de los ya
ocupados, el contenido se conserva: no se elimina ni se expulsa. Se recalculan
de inmediato el divisor y la carga, y se bloquean nuevos depósitos hasta que la
ocupación vuelva a estar dentro del máximo. Recuperar o soltar contenido sigue
siendo la vía para liberar slots.

### 5. Interfaz

El Inventario muestra `slots usados/máximos` y el peso total actual de la caja,
incluidos sus 10,000 kg propios. La línea general de Carga incorpora exactamente
el mismo valor. El peso individual seleccionado continúa mostrando el peso real
del objeto o pila antes de la reducción. El icono 64×64 suministrado se muestra
junto a esta línea; antes del regalo aparece atenuado con el texto `No
adquirida`. Intentar almacenar desde Inventario antes del regalo devuelve una
causa explícita y no cambia el objeto.

### 6. Adquisición y compatibilidad de guardados

- Un perfil nuevo se marca explícitamente como no propietario.
- El primer encuentro canónico con Palomo no concede la Caja ni abre comercio.
- La entrega queda reservada a `MAIN_M00_STATE_BOX_RECEIVED`, tras completar la
  rama de combate y encontrar a Palomo en el segundo piso.
- Cuando se conecte esa fase, el regalo añadirá sus 10 kg, habilitará los slots
  y sólo podrá ejecutarse una vez mediante `MAIN_M00_FLAG_MAGIC_BOX_GRANTED`.
- `CaelumPersistentCharacterState` es la fuente persistente de propiedad. Se
  guarda en `PreTravelled` y se restaura en `Travelled`; el campo vivo y el
  marcador técnico se sincronizan desde ese registro.
- La propiedad es independiente de la ubicación física futura de Palomo.
- Los perfiles confirmados creados antes de V4.32.0b conservan la Caja durante
  la migración. Esto evita perder acceso a contenido que ya estaba guardado.
- Una partida intermedia malformada que no posea la recompensa pero contenga
  banderas `InMagicBox` se sanea moviendo esas pilas al inventario personal; no
  se elimina ningún objeto.

### 7. Integración con el registro de misión V4.33.0b

`GrantMagicBoxFromPalomo()` deja de alterar el registro de misión por sí sola.
La misión canónica **Donde despiertan los perdidos** comienza al despertar y
su primer objetivo es buscar ayuda. Poseer una Caja de una partida anterior no
salta la Voz, la presentación de Palomo ni la orientación hacia Argento.

Al migrar V4.33.0a se reinicia únicamente el relato comercial descartado. La
Caja existente no se duplica ni se quita, y conserva exactamente contenido,
slots, peso y reducción. Esto permite probar el nuevo prólogo sin destruir
inventario de desarrollo y mantiene a los personajes nuevos en la progresión
canónica sin Caja.

El resolvedor de ubicación mantiene a Palomo oculto antes de la Voz, lo muestra
en el recibidor durante el encuentro, vuelve a ocultarlo al orientar hacia
Argento y reserva el segundo piso para la futura fase de entrega. La coordenada
y el traslado físico final todavía deben añadirse al mapa.

La prueba válida es cruzar el `Exit` del mapa o usar `changemap MAP02`. El
comando `map MAP02` comienza una partida nueva, crea otro jugador y debe mostrar
la Caja como no adquirida; por definición del motor no prueba persistencia.

## Diálogos nativos y audio

`GameInfo.AddDialogues` carga CAPALOMO; Thing_SetConversation y StartConversation
abren los menús nativos. Q equivale a Atrás; Escape y mando mantienen sus
controles del motor. Las páginas de la Voz tienen una sola salida Continuar.
Las probabilidades aparecen antes de elegir; el requisito de Ronnie permanece
visible y gris cuando está bloqueado. La emoción de Rulo es información privada.

La primera frase de Simple Harp Loop (2,571429 s, con caída de 450 ms) es
el `GameInfo.ChatSound` del proyecto. GZDoom emite una sola señal local al
abrir una conversación y al mostrar cada página siguiente: Voz, Palomo,
Argento, Rulo, Ronnie y Caella. No hay otra llamada manual al abrir. Una
opción bloqueada no pasa de página y no produce otra señal. La navegación
del cursor no equivale a avanzar el texto. La marca singular deja terminar
la frase en curso si se avanza muy rápido; evita acumular acordes superpuestos.
ChatSound también es la notificación nativa del chat del motor; no se modifica
su alcance local ni su autoridad. Véase ASSETS.md para procedencia y edición.

La portada reproduce una vez el War Drums de 6 s. CaelumMenuAudio solicita
reproducción sin bucle al entrar; no cambia volúmenes, música de mapas ni
listas personales. Los menús de pausa conservan la música de la partida.
Al elegir Salir/Exit en el menú principal, CaelumExitMenu abre la confirmación
nativa y reproduce menu_strings_start mientras el audio sigue activo. Cancelar
regresa al menú padre. QuitSound y el botón Exit del mapa conservan el mismo
recurso; la marca singular evita superponer dos instancias de las cuerdas.

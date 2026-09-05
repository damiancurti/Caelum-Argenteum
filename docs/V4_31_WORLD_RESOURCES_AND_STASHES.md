# V4.31 — fuentes naturales, modelos 3D y alijos

## Contrato visual y jugable aprobado

Las fuentes de materiales no se representan como pickups planos. Cada mina,
árbol, planta o alijo es un actor de mundo con modelo 3D semirrealista. Al
interactuar, la autoridad del juego resuelve el rendimiento y genera los
actores de inventario ya existentes, que conservan sus sprites. Así se separa
la presencia física del origen de la representación compacta de su contenido.

| Origen | Representación 3D | Resultado en sprites |
|---|---|---|
| Mina/veta | Roca o afloramiento disponible/depletado | Mena, metal bruto o gema según tabla |
| Árbol | Árbol/tronco disponible y variante talada | Madera de su grado |
| Planta | Mata disponible y variante recolectada | Fibra vegetal |
| Animal/monstruo | Actor vivo y cadáver normal | Piel en su tabla de muerte |
| Alijo | Baúl cerrado, abierto o bloqueado | Objetos persistentes del contenedor |

## Prototipo implementado en 4.31.0b

El primer alijo ya valida el tramo físico de esta arquitectura sin anticipar
las reglas de inventario. `CaelumStashChest` conserva el estado abierto/cerrado
y una variante `CaelumLockedStashChest` empieza bloqueada. La cerradura 201
acepta la `CaelumSilverKey` existente, nunca la consume y queda desbloqueada en
el actor después del primer uso correcto.

Tres OBJ originales representan cerrado, abierto y bloqueado. Las mallas usan
242, 254 y 266 caras respectivamente; sus texturas de madera, hierro, interior
y candado también se generan dentro del proyecto. Como OBJ no contiene
animación, un único actor sólido mantiene la lógica y crea un ayudante visual
sin colisión para el estado correspondiente. Esto evita superponer modelos y
deja el futuro contenido independiente de la representación.

Comandos de prueba:

```text
summon CaelumStashChest
summon CaelumLockedStashChest
give CaelumSilverKey
```

No hay todavía contenido, capacidad, propietario, robo, reposición ni
colocación permanente. Esos valores siguen reservados para la primera
implementación funcional de contenedores.

## Biblioteca física implementada en 4.31.0c

La primera biblioteca regional ya aporta 26 actores sólidos y convocables: 5
formaciones rocosas y 21 árboles o plantas, tres para cada clima solicitado.
Las siluetas no son recolores de una sola malla: varían altura, anchura,
ramificación, inclinación y copa. La colisión queda limitada al núcleo de la
roca o al tronco para que una copa ancha no forme una pared invisible.

| Grupo | Variantes | Clases | DoomEdNums |
|---|---|---|---|
| Rocas | Granito, estratos de arenisca, columnas de basalto, cuarzo, roca costera erosionada | `CaelumRockGranite`, `CaelumRockSandstone`, `CaelumRockBasalt`, `CaelumRockQuartz`, `CaelumRockCoastal` | 18041–18045 |
| Desierto | Cardón, churqui, chañar | `CaelumTreeDesertCardon`, `CaelumTreeDesertChurqui`, `CaelumTreeDesertChanar` | 18050–18052 |
| Selva | Lapacho, palo rosa, timbó | `CaelumTreeJungleLapacho`, `CaelumTreeJunglePaloRosa`, `CaelumTreeJungleTimbo` | 18053–18055 |
| Tundra | Lenga, ñire, guindo | `CaelumTreeTundraLenga`, `CaelumTreeTundraNire`, `CaelumTreeTundraGuindo` | 18056–18058 |
| Montaña | Pehuén, ciprés de la cordillera, coihue | `CaelumTreeMountainPehuen`, `CaelumTreeMountainCypress`, `CaelumTreeMountainCoihue` | 18059–18061 |
| Llanura | Ombú, tala, espinillo | `CaelumTreePlainsOmbu`, `CaelumTreePlainsTala`, `CaelumTreePlainsEspinillo` | 18062–18064 |
| Costa | Coronillo, sauce criollo, ceibo | `CaelumTreeCoastCoronillo`, `CaelumTreeCoastWillow`, `CaelumTreeCoastCeibo` | 18065–18067 |
| Ciudad | Jacarandá, tipa, plátano | `CaelumTreeCityJacaranda`, `CaelumTreeCityTipa`, `CaelumTreeCityPlane` | 18068–18070 |

La categoría jugable «tundra» usa vegetación del límite subantártico
patagónico en vez de inventar árboles de una tundra estrictamente desarbolada.
La selección regional se contrastó con la flora publicada por Parques
Nacionales: cardonales y churqui en Los Cardones; lenga, ñire, guindo, coihue,
ciprés y pehuén en Patagonia; tala, coronillo, ombú y espinillo en ambientes
centrales y costeros. Para ciudad se tomaron como referencia jacarandá, tipa y
plátano del arbolado porteño.

Referencias oficiales:

- https://www.argentina.gob.ar/ambiente/contenidos/areas-protegidas
- https://www.argentina.gob.ar/parquesnacionales/region-noroeste/parque-nacional-los-cardones/biodiversidad
- https://www.argentina.gob.ar/parquesnacionales/viveros-de-los-parques-nacionales/parque-nacional-nahuel-huapi-isla-victoria
- https://www.argentina.gob.ar/parquesnacionales/patagonia-austral/parque-nacional-tierra-del-fuego
- https://www.argentina.gob.ar/parquesnacionales/centro/parque-nacional-campos-del-tuyu/biodiversidad
- https://www.argentina.gob.ar/parquesnacionales/centro/parque-nacional-ciervo-de-los-pantanos/ficha-del-area-protegida
- https://buenosaires.gob.ar/gcaba_historico/noticias/los-arboles-mas-frecuentes-en-el-paisaje-porteno

Los 26 OBJ suman 14.932 caras; la malla individual más detallada es el pehuén
con 2.416. Cada actor usa un sprite transparente de anclaje, una malla estática
y un material de 256×256. El atlas maestro se conserva en
`assets/source/world/ca_environment_atlas_master.png`; el generador
determinista está en `tools/generate_environment_models.py`. Los resultados ya
se incluyen en `src/`, por lo que instalar, construir o probar el parche no
requiere Python.

En 4.31.0c estos objetos todavía no responden a Use ni entregan materiales. No
se asignaron de forma arbitraria herramienta, rendimiento, agotamiento o
regeneración. Pueden inspeccionarse con `summon <clase>` y colocarse en el
editor mediante los DoomEdNums de la tabla; su conversión a nodos funcionales
espera los valores de diseño enumerados al final de este documento.

## Repertorio ampliado en 4.31.0d

Las veintiuna especies tienen ahora tres actores y tres mallas propias. El
nombre original conserva el tamaño 100%; el sufijo `2` indica 75% y el sufijo
`3`, 125%. Las semillas deterministas cambian levemente ramas, inclinaciones o
distribución de copa, pero conservan la forma básica y el follaje de la
especie. Por ejemplo:

| Tamaño | Sauce criollo | Pehuén |
|---:|---|---|
| 100% | `CaelumTreeCoastWillow` | `CaelumTreeMountainPehuen` |
| 75% | `CaelumTreeCoastWillow2` | `CaelumTreeMountainPehuen2` |
| 125% | `CaelumTreeCoastWillow3` | `CaelumTreeMountainPehuen3` |

Las cinco formas de roca combinan cinco escalas nominales con esas mismas
tres variantes geométricas. Los nombres de escala se insertan antes del
sufijo visual:

| Escala nominal | Modelo 1 | Variante 2 (75%) | Variante 3 (125%) |
|---:|---|---|---|
| 0.5× | `CaelumRockGraniteHalf` | `CaelumRockGraniteHalf2` | `CaelumRockGraniteHalf3` |
| 1× | `CaelumRockGranite` | `CaelumRockGranite2` | `CaelumRockGranite3` |
| 2× | `CaelumRockGraniteDouble` | `CaelumRockGraniteDouble2` | `CaelumRockGraniteDouble3` |
| 5× | `CaelumRockGraniteGiant` | `CaelumRockGraniteGiant2` | `CaelumRockGraniteGiant3` |
| 20× | `CaelumRockGraniteColossal` | `CaelumRockGraniteColossal2` | `CaelumRockGraniteColossal3` |

El patrón se repite para `Sandstone`, `Basalt`, `Quartz` y `Coastal`. Son 63
actores de árboles y 75 de rocas: 138 en total. Los 112 nuevos DoomEdNums usan
el rango 18300–18411 sin alterar las asignaciones históricas. Hay 78 OBJ y
44.976 caras; las cinco escalas de una roca reutilizan sus tres mallas mediante
`MODELDEF`, por lo que no duplican geometría idéntica dentro del PK3. Todas las
escalas comparten la textura de su forma base.

La corrección visual de 4.31.0d une al tronco las ramas colgantes del sauce y
oculta dentro de la copa el extremo superior de los troncos de ciprés, guindo
y pehuén. Los demás modelos base permanecen byte-idénticos a 4.31.0c.

La colisión continúa siendo cilíndrica y deliberadamente aproxima el núcleo de
la roca o el tronco. Para rocas de escala 20× que deban funcionar como terreno
recorrible o cuevas, conviene acompañar el modelo con geometría de mapa o
líneas de bloqueo específicas; el OBJ no aporta colisión triangular al motor.

## Escala adulta y física ambiental en 4.31.0e

El autor aprobó las doce pruebas de 4.31.0d. Los 63 árboles ya existentes
conservan exactamente sus clases, mallas, materiales y escalas. En lugar de
convertirlos retroactivamente, 4.31.0e añade 48 actores para ejemplares adultos
de las dieciséis especies cuya altura anterior representaba un árbol joven o
el extremo bajo de su rango. Cada familia reutiliza las tres mallas aprobadas:
`Adult` es el tamaño central, `Adult2` mide 75% y `Adult3`, 125%.

| Familia | `Adult2` | `Adult` | `Adult3` |
|---|---:|---:|---:|
| Lapacho | 13,5 m | 18 m | 22,5 m |
| Palo rosa | 24 m | 32 m | 40 m |
| Timbó | 13,5 m | 18 m | 22,5 m |
| Lenga | 15 m | 20 m | 25 m |
| Ñire | 7,5 m | 10 m | 12,5 m |
| Guindo | 15 m | 20 m | 25 m |
| Pehuén | 24 m | 32 m | 40 m |
| Ciprés de la cordillera | 13,5 m | 18 m | 22,5 m |
| Coihue | 22,5 m | 30 m | 37,5 m |
| Ombú | 9 m | 12 m | 15 m |
| Tala | 6 m | 8 m | 10 m |
| Coronillo | 6 m | 8 m | 10 m |
| Sauce criollo | 11,25 m | 15 m | 18,75 m |
| Jacarandá | 11,25 m | 15 m | 18,75 m |
| Tipa | 15 m | 20 m | 25 m |
| Plátano | 16,5 m | 22 m | 27,5 m |

El patrón de clase es `CaelumTree<Bioma><Especie>Adult`, seguido opcionalmente
por `2` o `3`; por ejemplo, `CaelumTreeMountainPehuenAdult3`. Sus DoomEdNums
ocupan 18412–18459 sin cambiar ninguna asignación previa. El catálogo alcanza
111 actores arbóreos y conserva los mismos 63 OBJ de vegetación: las escalas
adultas se expresan en `MODELDEF`, por lo que no duplican geometría.

Todos los objetos ambientales reciben ahora una masa en kilogramos calculada
como `densidad × π × (radio/32)^2 × (altura/32)`. El radio y la altura son los
del cilindro de colisión, y las densidades nominales se redondean por especie o
familia de roca. Esta aproximación deliberada no suma por separado raíces,
ramas, huecos ni irregularidades invisibles del OBJ.

Los árboles continúan arraigados: participan en Impact Physics como un límite
estático equivalente a una pared, dañan por la desaceleración real y nunca
reciben velocidad. Las rocas sí son cuerpos movibles. Una colisión horizontal
resuelve acción y reacción con su masa real aproximada; al usar el comando de
empuje frente a ellas, el requisito es `masa/100` de Potencia física y la
velocidad recibida también disminuye con la masa. Una roca que alcanza al
jugador o a un actor de combate se resuelve desde el receptor, incluso cuando
el callback nativo llega por el lado pasivo.

La extracción sigue desactivada. Dureza, daño cortante/punzante, recompensas,
agotamiento, regeneración, menas especiales y algas pertenecen a la expansión
de recursos de Versión 5 documentada en
[`V5_RESOURCES_AND_MARINE_BIOMES.md`](V5_RESOURCES_AND_MARINE_BIOMES.md).

Los nodos naturales regeneran con tiempo. El actor debe guardar como mínimo su
identidad estable, estado disponible/depletado y tic/fecha de regeneración; el
modelo sólo comunica ese estado y nunca decide la recompensa. En red, una única
transacción consume el nodo o retira del baúl para impedir duplicaciones.

## Fuentes renovables y vetas compactas en 4.31.0f

Después de aprobar las catorce pruebas de 4.31.0e, todos los árboles pasan a
ser fuentes renovables de madera. Sólo aceptan el tramo melee cortante. Las
cinco rocas escénicas siguen sin entregar recursos; en su lugar se incorporan
vetas 3D inequívocas para hierro, carbón mineral, cobre, estaño, plata, oro,
ópalo, topacio, zafiro, rubí y esmeralda. Cada recurso tiene tres siluetas y
escalas de afloramiento, para 33 actores con DoomEdNums 18500-18532.

La extracción usa una sola fórmula:

`unidades por golpe = daño melee x max(0, 1 - dureza/10) x abundancia`

| Recurso | Dureza | Abundancia | Unidades por 100 de daño |
|---|---:|---:|---:|
| Madera | 2,5 | 100% | 75 |
| Hierro | 5,5 | 60% | 27 |
| Carbón mineral | 2,5 | 60% | 45 |
| Cobre | 3,5 | 50% | 32,5 |
| Estaño | 6,5 | 40% | 14 |
| Plata | 3 | 20% | 14 |
| Oro | 3 | 10% | 7 |
| Ópalo | 6 | 7,5% | 3 |
| Topacio | 8 | 5% | 1 |
| Zafiro | 9 | 4% | 0,4 |
| Rubí | 9 | 3% | 0,3 |
| Esmeralda | 7,5 | 2% | 0,5 |

El resultado no se tira al azar: toda fracción queda guardada hasta completar
una unidad. La capacidad por defecto es la masa del cilindro convertida a
gramos y multiplicada por abundancia; `arg4` permite que un mapa reemplace esa
capacidad expresándola en kilogramos enteros. Cada fuente parcialmente agotada
y cargada recupera 0,1% de su máximo durante las 24 horas canónicas de juego,
equivalentes a 72 minutos reales. Desde cero, la recuperación completa requiere
1.000 días de juego, consecuencia directa del porcentaje pedido.

Cardón, churqui, chañar, espinillo y ceibo conservan visualmente sus tres
tamaños, pero el editor los muestra como `Adult`, `Adult2` y `Adult3`. Los
nombres viejos siguen resolviendo partidas o mapas existentes. Cada familia
suma `Young`, `Young2` y `Young3` a 50% de la escala adulta correspondiente,
con DoomEdNums 18460-18474.

MAP01 y MAP02 no reciben vetas. Su colocación se reserva para regiones
geológicas aprobadas y para las futuras reglas de profundidad; Buenos Aires no
presenta minerales arbitrarios en superficie.

## Nombres completos y correcciones de fuentes en 4.31.0g

Las otras dieciséis especies conservan sus adultos ampliados y renombran en el
editor sus 48 ejemplares anteriores como `Young`, `Young2` y `Young3`. Sus
DoomEdNums, mallas, escalas, colisiones y masas permanecen iguales; las clases
históricas sin edad siguen disponibles como alias de compatibilidad. El
catálogo completo queda en 63 árboles Adult y 63 Young.

La extracción válida desgasta el arma, pero consulta explícitamente
`IsEnvironmentMovable()` antes de transmitir impulso. De este modo un árbol
arraigado no se desplaza al entregar madera y una veta conserva su respuesta
física basada en masa. Carbón 3, plata 1 y oro 2 omiten únicamente las bandas
minerales largas que sobresalían fuera de la roca; las inclusiones irregulares,
capacidad, abundancia, dureza y recompensa no se modifican.

Las capacidades exactas derivadas de masa se publican en
`CAPACIDADES_RECURSOS_4_31_0g.txt`. Las rocas escénicas continúan con capacidad
cero. No se cambia la recuperación diaria de 0,1%, ni se agregan fuentes a los
mapas de Buenos Aires.

## Fuentes recomendadas

### 1. Poly Haven — fuente principal semirrealista

Todos sus HDRI, texturas y modelos se publican bajo CC0; pueden modificarse,
redistribuirse e incluirse en un producto comercial sin atribución obligatoria.
Proporciona glTF/FBX y texturas PBR, pero varios maestros son demasiado pesados
para uso directo y deben reducirse antes de entrar al PK3.

- Licencia: https://polyhaven.com/license
- Catálogo de modelos: https://polyhaven.com/models
- Baúl de tesoro: https://polyhaven.com/a/treasure_chest
- Pino con LOD: https://polyhaven.com/a/pine_tree_01
- Tronco muerto: https://polyhaven.com/a/dead_tree_trunk_02
- Helecho: https://polyhaven.com/a/fern_02
- Caja de madera: https://polyhaven.com/a/wooden_crate_01

El `Treasure Chest` es un buen maestro visual para el primer alijo, pero sus
103.000 triángulos requieren una versión reducida y estados/animación de tapa
propios. El pino declara LODs, aunque su maestro completo tampoco debe incluirse
sin seleccionar la malla y las texturas de menor costo.

### 2. ambientCG — materiales PBR y apoyo semirrealista

Todos sus archivos descargables son CC0 y su licencia permite expresamente
copiar, modificar, distribuir e incluir los archivos crudos en un videojuego.
Es especialmente útil para piel de roca, mineral, corteza, madera, metal y
superficies de baúl, incluso cuando la malla base se modele o reduzca aparte.

- Licencia: https://docs.ambientcg.com/license/
- Catálogo: https://ambientcg.com/list

### 3. Kenney — prototipos y reserva de bajo costo

Los assets de sus páginas son CC0 y no exigen atribución. Su estilo suele ser
más limpio/low-poly que la mansión, por lo que conviene reservarlo para
prototipos, colisiones o piezas que luego reciban materiales semirrealistas.

- Política de licencia: https://kenney.nl/support
- Nature Kit (árboles, roca y follaje): https://kenney.nl/assets/nature-kit
- Mini Dungeon (piezas y cofres de prueba): https://kenney.nl/assets/mini-dungeon
- Survival Kit: https://kenney.nl/assets/survival-kit

### Fuente no prioritaria

Quaternius usa actualmente QAL 1.0. Permite incluir y comercializar assets
dentro de un juego, pero prohíbe redistribuir los assets —incluso modificados—
como assets. Esa distinción es incómoda para un repositorio público que contiene
fuentes de modelos, por lo que no se incorporará salvo revisión explícita del
archivo y la versión de licencia obtenidos.

- Licencia actual: https://quaternius.com/license.html

Sketchfab y OpenGameArt mezclan licencias por archivo. Sólo se aceptaría un
asset individual después de guardar su página, autor, licencia exacta y fecha;
"gratis" por sí solo no es suficiente.

## Conversión para GZDoom

1. Descargar preferentemente glTF/FBX y conservar el archivo de licencia junto
   al maestro fuera del runtime.
2. Abrir en Blender, unir materiales equivalentes, corregir pivote/escala y
   reducir la malla; mantener sólo los mapas PBR que el render realmente use.
3. Crear LODs o variantes disponibles/depletadas y una colisión simple en el
   actor, separada de la malla visible.
4. Exportar a un formato admitido por `MODELDEF` (preferentemente IQM para
   animación o MD3 para piezas rígidas) y convertir texturas a tamaños de juego.
5. Registrar el modelo, escala, skin y cuadro de estado en `MODELDEF`; nunca
   depender del sprite visible del pickup para representar la fuente.
6. Probar clipping, distancia de uso, oclusión, rendimiento y reemplazo de
   estado en GZDoom 4.14.2 antes de poblar un mapa completo.

## Arquitectura propuesta

`CaelumResourceNode` aporta estado, regeneración, interacción y transacción de
salida. Subclases de datos asignan familia, modelo disponible/depletado, tabla
de rendimiento y requisitos. Los drops se generan como actores de pickup con
una dispersión breve y límites de cantidad, de forma que sigan siendo visibles
y recogibles sin convertir cada material en otro modelo 3D.

`CaelumStash` reutiliza el servicio de inventario persistente y mantiene por
separado:

- propietario (jugador, NPC, facción o mundo);
- política de acceso/robo;
- estado cerrado/abierto;
- identificador de llave o dificultad de cerradura;
- capacidad y contenido persistente;
- autoridad multijugador.

El mismo modelo de baúl puede servir a jugador y NPC; la diferencia está en
los datos. El bloqueo no debe ser una clase visual distinta ni destruir el
contenido al abrirse.

## Valores que faltan antes de programar nodos y baúles

1. Tiempo de regeneración por árbol, planta y veta.
2. Cantidad fija/rango de cada cosecha y agotamiento por número de usos.
3. Herramientas y atributos requeridos, más el efecto de eficiencia/habilidad.
4. Tabla de pieles por familia de criatura y probabilidades/cantidades.
5. Si el recurso agotado cambia de modelo, desaparece o depende de su tipo.
6. Capacidad de alijos y si el jugador posee uno global o varios contenidos
   independientes.
7. Reglas de propiedad, robo, reacción del NPC/facción y multijugador.
8. Llaves, ganzúas, dificultad, rotura y posibilidad de forzar una cerradura.
9. Reposición de baúles del mundo/NPC y persistencia entre mapas.
10. Unidad monetaria y valores ancla para abrir después la economía.

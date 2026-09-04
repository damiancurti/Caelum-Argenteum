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

Los nodos naturales regeneran con tiempo. El actor debe guardar como mínimo su
identidad estable, estado disponible/depletado y tic/fecha de regeneración; el
modelo sólo comunica ese estado y nunca decide la recompensa. En red, una única
transacción consume el nodo o retira del baúl para impedir duplicaciones.

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

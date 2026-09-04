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

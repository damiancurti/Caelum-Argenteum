# Versión 5 — expansión de recursos y biomas marinos

## Alcance aprobado y primer tramo funcional

La extracción de madera y del catálogo mineral compacto se adelanta de forma
aislada en 4.31.0f. Las fuentes son modelos 3D y liberan los objetos de
inventario existentes como pickups con sprites. Pieles, fibras, recursos
marinos, economía regional y el calendario capaz de compensar mapas no
cargados permanecen en Versión 5 después de la transición modular. Las tiendas
permitirán comprar y vender todos los materiales, incluso cuando su origen
natural todavía no aparezca en la región.

Buenos Aires no tendrá vetas minerales comunes a simple vista durante el
inicio. La minería aparecerá al viajar a regiones geológicamente apropiadas y
al aumentar la profundidad. Las rocas ambientales genéricas —granito,
arenisca, basalto, cuarzo escénico y roca costera— no entregarán metales al
azar: cada recurso procederá de una veta, mena o depósito 3D identificable.

## Interacción y dureza

- Sólo las armas cuerpo a cuerpo podrán extraer materiales.
- Los árboles requerirán daño cortante.
- Las vetas, menas y depósitos rocosos requerirán daño punzante.
- La dureza aplicará el multiplicador de desprendimiento
  `max(0, 1 - dureza/10)` antes de rareza, profundidad y habilidad.
- Madera con dureza 2–2,5 conservará aproximadamente 80–75% del rendimiento
  previo a rareza; granito con dureza 6–7 conservará 40–30%.
- Los árboles permanecerán arraigados. Las rocas y menas que su tamaño y masa
  permitan podrán desplazarse mediante Impact Physics.
- Capacidad, agotamiento y fracciones son autoritativos y persistentes. Cada
  nodo cargado recupera 0,1% de su máximo por día de juego; la compensación
  entre mapas descargados se conectará al calendario global de V4.35/V5.

Los factores de daño del combate y el rendimiento de extracción serán capas
separadas. Un golpe puede causar su daño normal y, sólo si es cuerpo a cuerpo y
del tipo correcto, intentar desprender material. Así un proyectil punzante no
se convierte accidentalmente en herramienta minera.

## Catálogo mineral compacto implementado en 4.31.0f

| Grupo | Recursos previstos | Probabilidad base acordada |
|---|---|---:|
| Comunes | Hierro, carbón mineral | 60% |
| Común intermedio | Cobre | 50% |
| Común menos abundante | Estaño | 40% |
| Precioso | Plata | 20% |
| Precioso raro | Oro | 10% |
| Gemas | Ópalo, topacio, zafiro, rubí, esmeralda | 5% antes del multiplicador propio |

Multiplicadores de gema acordados sobre la base del 5%:

| Gema | Multiplicador | Probabilidad resultante |
|---|---:|---:|
| Ópalo | 1,5× | 7,5% |
| Topacio | 1× | 5% |
| Zafiro | 0,8× | 4% |
| Rubí | 0,6× | 3% |
| Esmeralda | 0,4× | 2% |

Los porcentajes se aplican como rendimiento determinista y las fracciones se
acumulan en la fuente. La profundidad aumentará la oportunidad de recursos valiosos y cada región
habilitará únicamente depósitos compatibles con su geología. Los
multiplicadores exactos de profundidad y región permanecen pendientes para no
inventar balance antes de construir los mapas correspondientes.

Piedra común y arena no entran todavía al inventario porque no poseen una
cadena jugable suficiente. Azufre nativo y salitre se reservarán para química
y pólvora; el carbón vegetal se fabricará con madera y no se confundirá con el
carbón mineral. El yodo no procederá de una roca genérica: podrá comprarse en
boticas y, al incorporarse los biomas marinos, obtenerse mediante algas o
procesamiento de salmueras.

## Biomas marinos y costa

Versión 5 ampliará la costa hacia biomas marinos con fuentes 3D submarinas. El
primer catálogo previsto comprende algas recolectables y deja preparados
otros orígenes —salmueras, conchas, perlas, coral y depósitos submarinos— sin
activarlos hasta que tengan recetas, economía y efectos propios.

Las algas serán el primer puente entre exploración marina y botica. Su actor 3D
deberá reaccionar al movimiento del agua sólo si esa animación mantiene el
presupuesto del mapa; al interactuar liberará el pickup en sprite y pasará a un
estado recolectado hasta regenerarse. La respiración seguirá usando la única
barra compartida de Aire ya validada en 4.31.0d.

## Materiales no minerales relacionados

- Madera y carbón vegetal: árboles y procesamiento.
- Fibra vegetal y algodón: plantas.
- Pieles: tablas de muerte de animales o monstruos.
- Alcohol: fermentación y destilación.
- Opio medicinal: amapola.
- Corteza de quina: origen vegetal o comercio regional.
- Yodo: algas, salmueras o comercio de botica.
- Grasa y cera: animales o abejas.

Las recetas definitivas de medicamentos, pólvora, bombas y munición se
incorporarán sólo cuando cada ingrediente tenga actor, procedencia, precio y
unidad de inventario definidos.

## Pruebas obligatorias del tramo 4.31.0f y de la expansión posterior

1. Confirmar que ataques a distancia nunca entreguen materiales.
2. Confirmar cortante para árboles y punzante para menas.
3. Verificar dureza, rareza, profundidad y región por separado y combinadas.
4. Probar agotamiento, guardado/carga, regeneración y autoridad multijugador.
5. Limitar la cantidad de pickups simultáneos para evitar regresiones masivas.
6. Validar tiendas como vía alternativa en Buenos Aires.
7. Probar navegación, Aire y recolección en cada profundidad del bioma marino.
8. Auditar licencias y procedencia de cada modelo, textura y sonido nuevo.

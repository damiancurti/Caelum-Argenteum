# Caelum Argenteum — Audio y arte

Versión documental: 4.35.0e — 2026-09-16.

## 4.35.0e — mobiliario original y vista de descanso

Dos OBJ originales se generan con assets/generators/generate_rest_furniture.py,
usando únicamente la biblioteca estándar y Mesh del generador de depósitos:

- src/models/caelum/props/rest/ca_rest_chair.obj: silla de madera con respaldo.
- src/models/caelum/props/rest/ca_rest_bed.obj: catre bajo con marco, lona y almohada.

Reutilizan materiales de madera, metal e interior propios del depósito. No se
crean ni modifican PNG. MODELDEF enlaza ambos modelos con CAHC A, el sprite de
control transparente ya disponible; aplica escala 1, AngleOffset -90 y corrección
de proporción de píxel. Los actores tienen colisión propia. Se reutilizan las
ocho rotaciones de RestSeated/RestLying de Domingo, sin alterar esos sprites.
Los ajustes WorldOffset de la sesión son exclusivamente gráficos y se deshacen
al levantarse.

El panel de descanso pasa a (16,12,608,102) en 640×360 y oscurecimiento 0,12.
Agrupa fecha y duración, recursos y controles arriba para dejar visible el
personaje. LANGUAGE incorpora siete claves nuevas por idioma: títulos,
descripciones, falta de alcance/espacio y ayuda de cámara. CAPALOMO añade dos
conversaciones con las mismas cuatro duraciones y el menú aprobado. Flechas,
filtros, Misiones, RePág/AvPág y liberación de Use conservan su implementación.

Se inspeccionaron capturas nativas de GZDoom 4.14.2 en Linux, ajustando escala,
orientación y colocación de ambas poses. Son modelos sencillos de prueba con
sprites de ocho vistas; no se incorporan modelos animados de personajes.
La prueba de Windows permite revisar la presentación con la resolución y
renderizador habituales del autor.

No cambian MAPINFO, geometrías WAD, audio, texturas, sprites ni modelos previos.
El ZIP incluye el generador y fuentes nuevas/modificadas, sin motor, IWAD,
PK3 completo ni material QA. ca_debug_rest_report identifica 4.35.0e.

## 4.35.0d1 — resolución de las poses existentes

El hotfix corrige únicamente las búsquedas de estados de descanso y vuelve a
incluir el catálogo necesario del Limbo. RestLying/RestSeated conservan sprites,
colisión y presentación de 0d; no se añade o cambia ningún recurso audiovisual.
El informe de descanso identifica 4.35.0d1; los otros informes conservan 0d.
Se compiló con GZDoom 4.14.2; no se declara una comprobación visual jugable.

## 4.35.0d — interfaz y poses del descanso

Nuevas fuentes CaelumRest.zs y CaelumRestTrial.zs, incluidas al final de ZSCRIPT.
CAPALOMO añade la conversación 43510 sobre el menú común aprobado, con modos,
duraciones y preparaciones explícitas. LANGUAGE añade las claves inglesas y
españolas correspondientes; la ayuda de Mundo incluye D/X junto a C/Y y Use.

Se reutilizan RestLying/RestSeated de Domingo (RSDO B/A). No se crean sprites,
camas, sillas, mapas o modelos. La pose mundial no cambia altura, radio ni
colisión. La vista sigue siendo la habitual del jugador, con un panel de
descanso y oscurecimiento de fondo 0,30; la cámara prevista queda pendiente.

El panel ocupa (56,88,528,184) en 640×360. Muestra modo, fecha de campaña,
minutos restantes, Sueño/Hambre/Sed con dos decimales y controles. Las métricas
conservadoras de las líneas nuevas caben en 504 MU; no se considera una captura
nativa de GZDoom. La UI conserva flechas, extremos y RePág/AvPág; se resuelve
X de Mundo antes del latch de abandono para no retener la entrada de Misiones.

MAPINFO, WAD de los seis mapas, fuentes, audio, sprites, modelos, generadores
y menús de conversación existentes mantienen sus bytes. Los informes llevan
el identificador 4.35.0d. No se entrega motor, IWAD, PK3 completo ni fixtures QA.

## 4.35.0c — presentación del tiempo detenido

Mundo reutiliza sus dos líneas temporales, fuentes y coordenadas. En MAP01,
la línea superior muestra «El tiempo está detenido en el Limbo»; la inferior
muestra la fecha canónica o la vista de prueba expresamente identificada.
LANGUAGE añade CA_WORLD_CLOCK_TIMELESS en inglés/español y cambia el mensaje
de calendario aún no inicializado. No se amplía el panel ni cambia la entrada
de teclado/mando. La revisión de métricas se realiza sobre las fuentes
existentes; la inspección visual dentro de GZDoom queda en las pruebas de 0c.

Se modifican WorldCatalogue, WorldClock, Calendar y la presentación de Mundo;
las cabeceras de los informes existentes identifican 4.35.0c. Se conservan
MAPINFO, las conversaciones sin pausa aprobadas, geometrías, llegadas, accesos,
puestos, sprites, fuentes, modelos, sonidos y generadores. No se crean assets.

## 4.35.0b — calendario sobre la presentación existente

Nueva fuente src/caelum/world/CaelumCalendar.zs e include en ZSCRIPT. LANGUAGE
añade ocho claves inglesas/españolas para fecha, límites y estaciones. Mundo
añade una línea en (48,160), ajusta ambas columnas y conserva la navegación.
Los cinco lugares visitados y las tres salidas caben en el panel previsto;
el autor confirmó después todas las pruebas de 0b, incluida su presentación.

MAPINFO activa conversaciones sin pausa en MAP01–MAP05 y CADEV02. Se modifica
Ticker del menú común en CaelumPalomoDialogue.zs; no se reemplazan árboles
USDF, formato, voces, arpa, sprites, fuentes ni efectos de captura. No hay
recursos audiovisuales nuevos, mapas regenerados ni generadores modificados.
Los iconos/efectos de las habilidades recién definidas no se entregan en 0b.

## 4.35.0a — presentación del tiempo registrado

No se agregan ni regeneran recursos audiovisuales o mapas. Se usa CaelumSmall
y el panel existente de Mundo para una línea de tiempo en (48,148), antes de
las columnas de visitas y salidas. LANGUAGE agrega dos claves en inglés y
español: tiempo registrado/escala e inicio del registro con perfil confirmado.

Nueva fuente src/caelum/world/CaelumWorldClock.zs incluida desde ZSCRIPT.
MAPINFO registra CaelumWorldClockTicker como observador estático para que se
active también con guardados anteriores. Los WAD, geometría, llegadas, accesos,
puestos de prueba, sprites, modelos, fuentes, audio y generadores se conservan.
Las marcas del último viaje se consultan en el informe de viajes existente.


## 4.34.0e — puestos de prueba en las alcantarillas

Se reutilizan sin modificar los modelos, sprites y sonidos de banco de trabajo,
aserradero y forja, junto al sello de quintaesencia y materiales nativos.
No se generan assets ni mapas. Se agrega CaelumSewerTrialSupport.zs y su include
ZSCRIPT; CAPALOMO conserva las páginas 43410–43413 y agrega dos respuestas
localizadas en inglés/español. La infraestructura usa sus clases concretas,
por lo que conserva las asociaciones MODELDEF existentes.

MAP02: banco (-320,64,0), aserradero (-320,120,0), forja (-264,120,0).
MAP03–MAP05: banco (-80,384,0), aserradero (-80,440,0), forja (-24,440,0).
Los nodos forman una red separada por proximidad y se conservan en el hub.
Son objetos del escenario; los recursos sólo se conceden al pedir la prueba.


## 4.34.0d — recursos del servicio de viaje

No se añaden ni regeneran mapas, imágenes, sprites, modelos o sonidos.
MAP01, MAP02, MAP03–05, CADEV02, MAPINFO, TEXTURES y los generadores conservan
sus bytes de 0c. La prueba usa el diálogo USDF y las fuentes ya integradas.

Nuevas fuentes: src/caelum/world/CaelumJourney.zs y CaelumCaravanTrial.zs,
registradas en ZSCRIPT. CAPALOMO contiene las cuatro ofertas nativas 43410–43413
y sus confirmaciones, con claves inglesas/españolas en LANGUAGE. El guía de
la prueba es invisible, temporal y sin assets propios. No se reutiliza el
nombre ni la identidad de un residente para representar a una caravana.

El diálogo, el servicio común, el registro de mundo, su presentación y la
reanudación de conversación son las integraciones tocadas por 0d. Las
cabeceras de diagnóstico anteriores se actualizan a 0d, sin cambiar su lógica.
No se distribuyen los recursos privados usados para ejecutar QA en GZDoom.


4.34.0c añade MAP03.wad, MAP04.wad y MAP05.wad, generados como UDMF nativo
por assets/generators/generate_sewer_trials.py. Usa sólo la biblioteca propia:
CASWRWAL para mampostería/bóveda, CASWRFLR para piso seco y CAPOOL01 para los
canales visuales bajos. El portón CSGTA0 referencia el CMGT01.png ya existente;
no se edita ni crea otra imagen. Las geometrías de MAP01/MAP02/CADEV02 no cambian.

El generador es Python estándar, sin dependencias externas. Se ejecuta con
python assets/generators/generate_sewer_trials.py y admite --output para una
salida alternativa. Sólo escribe MAP03–05; no es necesario para jugar ni para
run_dev.bat, ya que los WAD listos están incluidos. Se comprueba que regenerar
los tres mapas produce exactamente los mismos bytes.

No cambia audio, imágenes, modelos ni tipografía. MAP03–05 reutilizan CA_MUS02
y el viaje conserva el sonido nativo del jugador. Mundo y los rótulos de
acceso tienen textos españoles/ingleses. Se revisan capturas de portón,
depósito, cámaras, escaleras y el Diario completo en ambos idiomas. Los mapas
de prueba no incorporan enemigos, ítems o cartas automáticamente. El motor,
IWAD, marcadores de QA y capturas privadas quedan fuera de la entrega.

4.34.0b conserva mapas, sprites, modelos, gráficos, tipografías, música y audio
de 0a. La presentación opcional reutiliza CaelumSlidingDoorLeaf y sus
bloqueadores; la llave nativa usa el icono de llave existente y es un marcador
de prueba sin fila de equipo. LANGUAGE añade mensajes españoles/ingleses.

Las cerraduras LOCKDEFS 200, 201 y 202 usan el OGG propio de puerta bloqueada
ca_door_locked.ogg mediante su alias existente; no se añade audio. CheckKeys
emite un solo feedback nativo limitado por el temporizador, sin reproducción
manual superpuesta. Se revisan las escenas y mensajes nativos de la prueba en
MAP01/MAP02 y ambos idiomas. Los recursos privados de QA quedan fuera del ZIP.

4.34.0a conserva todos los mapas, modelos, gráficos, fuentes, música y audio
de 0ao. Mundo reutiliza panel, icono y fuentes del Diario y los nombres de
MAP01/MAP02 ya localizados; LANGUAGE añade ubicación, visitas, conexión,
estado, destino oculto y ayudas en español/inglés. No hay recursos nuevos.
Se revisa el render nativo antes del regreso, con conexión conocida y tras
llegar, incluidos los textos españoles e ingleses. Los créditos e inventarios
de recursos siguen vigentes; la exportación de prueba se preparará después de
4.37, antes del alcance heredado/transversal de V5.

0ao conserva byte a byte todos los mapas, modelos, gráficos, fuentes, música,
audio y LANGUAGE de 0an. El diagnóstico nuevo sólo escribe en consola a petición;
no incorpora imágenes, voces ni elementos permanentes del HUD. La reapertura
de conversaciones guardadas reutiliza el menú y su sonido nativos existentes. La comprobación
de integración usa las conversaciones y la salida ya aceptadas. No se regeneran
assets ni se redistribuyen el motor o el IWAD empleados en QA.

0an conserva byte a byte mapas, modelos, gráficos, fuentes, música y audio
de 0am. La prueba de reputación reutiliza la hoja de puerta deslizante y los
menús nativos existentes; guía y marcador de habilitación son invisibles.
LANGUAGE incorpora español/inglés para requisitos, estados, ayuda del Diario
y comercio de prueba. Este comercio muestra título y etiquetas genéricos,
con una indicación distinta para la rebaja temporal por reputación. No se
presenta como un nuevo NPC de la historia ni necesita arte o voces nuevas.
Se inspeccionan los renders nativos de ambos idiomas; evidencia en PROJECT.md.

0am conserva todos los recursos gráficos, mapas, modelos, fuentes y audio
de 0al. Las ayudas del Diario en español e inglés añaden una segunda línea
para explicar el cambio de solapa en los extremos. Se revisa su encaje en
el render nativo de Inventario y Misiones. Captura y regreso cambian sus
comprobaciones de diálogo, sin retocar sprites, música ni animaciones.

0al conserva todos los recursos de 0ak. Se revisan las ayudas del Inventario
y el caso de una sola misión, en español e inglés, con el arte y las fuentes
existentes. El diagnóstico de captura imprime texto en la consola a petición;
no añade elementos al HUD ni cambia la imagen de la esencia o de la carta.

0ak conserva mapas, imágenes, audio, modelos y fuentes de 0aj. La reparación
de posiciones ocurre sobre los actores existentes de MAP01; no añade ni
retoca modelos o geometría. Las ayudas del Diario se actualizan en español
e inglés y reutilizan las fuentes y el arte actuales. La revisión visual
cubre lista de misiones, Detalle e Inventario; evidencia en PROJECT.md.

0aj conserva imágenes, mapas, audio, modelos y fuentes de 0ai. Las constancias
de diagnóstico usan Inventory invisible y no requieren sprites nuevos. La
interfaz reutiliza el arte y las fuentes existentes del Diario.

## Recipientes nuevos — 4.33.0af

Seis ilustraciones originales generadas con la herramienta integrada de imagen,
una por modelo; sin recursos de Doom. Fuentes PNG RGBA en
assets/art_source/water_0af/{bottle_small,bottle_normal,bottle_large,
canteen_small,canteen_normal,canteen_large}.png.
Iconos RGBA de 128x128 con alfa conservado en src/graphics/caelum/icons/water/,
mismos seis nombres. Sprites de suelo src/sprites/CW0XA0.png a CW5XA0.png,
orden botellas pequeña/normal/grande, cantimploras pequeña/normal/grande;
offsets grAb (64,128), escala mundial 0,25 heredada del consumible.
No se sustituyen imágenes existentes. Audio, modelos y mapas conservados.

Prompt común de generación: "One game inventory sprite. Nineteenth-century
Argentina dark fantasy, semi-realistic hand-painted pixel art matching
Darkest Dungeon and Blasphemous; dark warm brown outlines, aged materials,
top-left light; single upright centered object, three-quarter frontal view,
readable at 96 pixels, 15% transparent padding, genuine RGBA transparency.
No text, numbers, plastic, weapons, cups, scenery or grid."
Variantes: small narrow olive-green corked glass bottle with neck twine;
normal broad amber corked glass bottle with leather base sleeve; large green
corked demijohn with wicker basket and handle; small round leather-covered tin
canteen; normal oval stitched leather-covered tin canteen with looped strap;
large rounded rectangular reinforced leather-covered tin canteen, brass cap
and folded strap. Capacidades 1/2,5/5 L respectivamente por familia.
Adaptación técnica: reducción a 128x128 y offsets PNG de GZDoom; no repintado.


## Revisión 4.33.0ae

Se reutilizan los cinco iconos de sellos, sus actores de equipo, el indicador
lateral del HUD y los efectos de Channel existentes. Las recetas aparecen en
Oficios con esos recursos. El diálogo usa las mismas fuentes y sonido de arpa.
No se agregan ni modifican WAD, arte, sprites, modelos, música, sonidos o
archivos de assets respecto de 0ad aprobado. Revisión visual en PROJECT.md.

## Revisión 4.33.0ad

Se reutilizan los iconos T1 de las cuatro familias de armadura, modelos de
estaciones, cajón, árboles, arbustos y vetas existentes. No se añaden recursos
visuales ni sonidos. MAP01/MAP02/CADEV02 y todos los audiovisuales mantienen
los bytes de 0ac aprobado. La limitación de recolección no cambia las masas
físicas ni la dureza de sus actores. Evidencia visual y técnica en PROJECT.md.

## Revisión 4.33.0ac

La receta de virotes usa ca_bolt_ammo.png y el actor CaelumBoltAmmo/CBOL que ya
existían. Flechas conservan su icono y actor propios. Se reutilizan interfaz,
fuentes, sonidos y estaciones; no hay activos nuevos. Los tres WAD, arte,
modelos y audio mantienen los bytes de 0ab aprobado. No se amplían mapas.

## Revisión 4.33.0ab

Se reutilizan la piscina y sus dieciséis escalones, el diálogo nativo de Ronnie,
el sonido de arpa y las fuentes de Detalle. No se crean iconos ni marcadores.
Los tres WAD, modelos, sprites, música, audio y fuentes de arte conservan los
bytes de la base 0aa aprobada. La indicación de ubicación está en el diálogo
y el Diario. Pruebas y revisión visual documentadas en PROJECT.md.

## Revisión 4.33.0aa

No se añaden ni modifican archivos de arte, sonido, música, modelos o mapas.
El Diario reutiliza El Loco y el reverso existente; muestra texto de pasivas
menores con las fuentes actuales. El barrido utiliza el selector nativo de las
armas grandes y su presentación provisional; el arte de primera persona de
esas armas permanece planificado. No se generan ilustraciones de cartas aún
sin contenido jugable. Revisión visual del Diario en PROJECT.md.

## Revisión 4.33.0z

Mapas, audio, arte, modelos y generadores idénticos a 0y aprobado. La práctica
de carga usa sobrantes propios y los controles existentes del inventario.
No agrega objetos de tutorial ni construye mapas. Alcantarillas diferidas.

## Revisión 4.33.0y

Sin cambios de WAD, arte, modelos, audio o generadores respecto de 0x aprobado.
La práctica usa pasillos existentes y el diálogo habitual de Ronnie. No agrega
marcadores, consumibles o una ruta de mapa. Las alcantarillas siguen diferidas.

## Revisión 4.33.0x

Sin cambios en los tres WAD, arte, audio, modelos ni generadores. La práctica
reutiliza raciones, iconos y diálogos existentes. No se construyen mapas nuevos.
La entrega 0w acumulativa fue aprobada por el autor.

Este acumulativo sobre 0u incluye MAP02, CADEV02 y el generador de 0v.
MAP01 permanece idéntico a 0u.

## Revisión 4.33.0w

No se agregan ni modifican arte, audio, modelos o mapas. La lección de Ronnie
reutiliza el diálogo nativo y la frase de arpa aceptada. Se conservan los 74
audios, las doce estaciones y sus fuentes. Los tres WAD mantienen sus hashes.

## Puerta de retorno y llegada a alcantarillas (4.33.0v)

MAP01.wad conserva exactamente el archivo aprobado. Al cargar, el controlador
sustituye visualmente el panel SW1EXIT por la puerta propia CMDR03 y, después
de capturar El Loco, coloca el marcador CTAR ya existente. No se modifican
sprites, texturas, modelos ni sonidos aceptados.

MAP02 reutiliza CASWRWAL (ladrillo), CASWRFLR (piedra), CAPOOL01 (agua, teñida
por el sector) y CMGT02 (reja del fondo). La llegada tiene 84 sectores,
187 líneas y un inicio de jugador, sin enemigos ni objetos del diagnóstico.
El generador reproducible es assets/generators/build_sewer_arrival.py; sólo
reescribe src/maps/MAP02.wad. La ambientación completa se amplía después.

CADEV02 conserva el TEXTMAP anterior de MAP02 con sus 16.508 cosas: sólo cambia
el marcador de nombre del WAD. MAP02 y CADEV02 reutilizan CA_MUS02. Los 74
archivos de audio, 12 modelos de estaciones y sus fuentes siguen sin cambios.

## Vista de espada (4.33.0u)

Se conserva todo el arte aprobado. DSHD y LHND son capas independientes de
escudo/mano izquierda; no forman parte del sprite de la espada DSWD.
La corrección elimina las capas 10/20 cuando no existe un escudo utilizable
equipado y las restaura para un objeto real. No se retocan sprites, modelos,
sonidos, mapa ni fuentes. El prototipo visual de consola sigue separado del
selector de arma que usa el préstamo de Ronnie.

## El Loco de las Pampas (4.33.0t)

0s aceptado por el autor. Se reutiliza su ilustración original aprobada
“El Loco de las Pampas.png”, 1024×1536, sin cambiar píxeles. Runtime:
src/graphics/caelum/tarot/ca_tarot_fool.png. TEXTURES registra CFLFA0 con
XScale/YScale 8 y Offset 512,1536; la esencia usa Scale 0.25 (32×48 MU).
El Diario encaja el mismo archivo en 104×156 unidades virtuales, conservando
la proporción de la ilustración en 16:9 y 4:3. No hay copia
adicional en assets porque el original y la versión runtime son idénticos.

Antes de examinarla se reutiliza ca_tarot_back.png/CTARA0. La captura genera
una imagen CFLF sin colisión que se acerca y reduce durante 35 tics. Se
reutilizan reveal_sting y player/level_up, además del arpa nativa del diálogo.
La música se atenúa durante la revelación y se restaura al cerrar. No se
agregan audios ni modelos. MAP01.wad sigue idéntico a 0s; el controlador
reconstruye la aparición a partir del estado de misión.

## Reutilización en 4.33.0s

0r aceptado por el autor. Palomo conserva sprites, escala, estados y recorrido.
El nuevo diálogo usa ConversationMenu/USDF, LANGUAGE en español e inglés y el
arpa nativa existente al abrir/avanzar. La entrega reutiliza el sonido de pickup.
La Caja conserva la interfaz/icono actual; su nueva instancia de identidad es
invisible en el mundo y no añade una fila ni un dibujo duplicados. No hay
sprites, modelos, música o texturas nuevos; MAP01.wad permanece idéntico.
La representación de El Loco se incorpora en 0t, descrita arriba.

## Reutilización en 4.33.0r

0q aprobado salvo la interacción poscombate. Se mantienen sprites, voces,
modelos, música y MAP01.wad. La caída protegida reutiliza CrouchIdle; la
recuperación usa Spawn y restaura la altura física si un guardado la redujo.
No se alteran índices de estados ni se añaden assets. El texto de Rulo cambia
en español e inglés. La aparición/carta de El Loco en la cueva se preparará
con el bloque Palomo/Caja; no hay un nuevo sprite de esencia en este delta.

## Reutilización en 4.33.0q

Los cuatro residentes conservan sus actores, sprites, escala, animaciones de
ataque y sonidos. La caída temporal en la prueba reutiliza CrouchIdle y las
poses agachadas entregadas por el autor; la recuperación vuelve a Spawn/See.
El cuero usa CaelumMaterialPickup y su icono actual. No se crean ni sustituyen
assets; el WAD y las 38 estaciones siguen iguales. Resto de 0p aprobado.

## Reutilización en 4.33.0p

El blanco de Rulo reutiliza CaelumTrainingDummy y su sprite CDMY, radio 21 y
altura 72; se coloca en (-290,480,0), debajo del dormitorio del personaje.
El Toro reutiliza BULL y sus fotogramas de preparación/cornada/muerte; se
extiende la anticipación y se añade desvanecimiento al cadáver. No hay dibujos,
modelos, texturas, poses ni audio nuevos. Los diálogos mantienen el arpa nativa
y los avisos usan la interfaz ya existente. No se distribuyen assets en el delta.

## Revisión 4.33.0o

0n aprobado por el autor. Se retira del mundo el manual exterior de MAP01;
su sprite CBOO y el icono ca_book.png siguen usados por libros y otros objetos.
No se elimina ni modifica ningún recurso visual, modelo o audio.

## Recursos reutilizados en 4.33.0n

Cinco vetas 3D CaelumVeinRuby, Sapphire, Emerald, Topaz y Opal se colocan al fondo
de la cueva; conservan masas, durezas y abundancias. El cajón existente queda
para cuero y mantiene modelo/animación. La munición reutiliza CaelumArrowAmmo
y su icono. El Toro conserva su arte; Palomo corre con PALM B/C y espera con A.
No se genera ni modifica arte, audio, modelos o poses. Las estaciones sólo
cambian colocación y guardas de interacción. No hay archivos de assets en este
delta porque sus contenidos mantienen las huellas de 0m.

## Arbusto de fibra 2D (4.33.0l)

Actor CaelumFiberBush; veinte ejemplares alrededor de la entrada de MAP01.
Billboard con transparencia real, sin MODELDEF. En 0m: escala 0,05, radio 20 MU,
altura 48 MU, masa aérea estimada 10 kg (SYSTEMS.md). No se retocan los PNG.
Se reutiliza la extracción de CaelumTreeEnvironmentProp, con fibra como salida.

- Fuente: `assets/source/art/ca_fiber_bush.png`. PNG RGBA 1430×1100, generado con la herramienta integrada
  de generación de imágenes de OpenAI, modo imagen nueva a partir de texto.
- Runtime: `src/sprites/caelum/world/CFBHA0.png`. Conserva exactamente los píxeles de la fuente y añade
  sólo el chunk PNG grAb (715,1018) para apoyar el tallo en el suelo.
- Prompt de creación: un solo arbusto silvestre fibroso, vista frontal para
  sprite de un RPG/FPS de fantasía oscura ambientado en Argentina del siglo XIX;
  follaje denso verde oliva apagado con hojas estrechas y tallos de paja claros,
  arbusto completo, iluminación neutra desde arriba a la izquierda, pintura
  semirrealista coherente con árboles/rocas del juego, fondo transparente real,
  sin texto, sin objetos adicionales, sin suelo ni sombra rectangular.
- La versión elegida es la primera generación con alfa auténtico. Las dos
  pruebas posteriores con transparencia simulada se descartaron y no se entregan.
- SHA-256 fuente: `efe14e3da2f2789c00cdf6cfdde9ae10655a75911b78570f239358d36ae936d0`.
- SHA-256 runtime: `83e902028d41dc5ba922489b831b311a85800f62ba98d63c1fddb67eecfc7b7a`.

La captura en GZDoom confirma silueta legible, fondo transparente y apoyo en
el piso. El cofre de suministros hereda el modelo y animación del alijo existente;
no duplica malla, textura ni sonido. Los modelos de estaciones siguen aceptados.

## Poses entregadas por el autor (4.33.0m)

Se integran Caelum_Argenteum_Poses_Agachados_v3.zip y los cuadros B acostados
de Caelum_Argenteum_Poses_Descanso_v2.zip, que v3 mantenía como dependencia.
Los 280 PNG de runtime son copias byte a byte de las entregas: 256×256 RGBA,
ocho direcciones, offset grAb (128,244). A sentado sin silla; B acostado;
C agachado quieto; D/E/F/G caminata agachada. No se genera ni redibuja arte.

| Personaje | Prefijo | Actor |
| --- | --- | --- |
| Rulo | RSRU | CaelumRulo |
| Ronnie | RSRO | CaelumRonnie |
| Argento | RSAR | CaelumArgento |
| Caella | RSCA | CaelumCaella |
| Domingo | RSDO | CaelumPlayer |

- Runtime: `src/sprites/caelum/rest/` con las cinco subcarpetas de personajes.
- Fuentes v3: `assets/source/art/poses_v3/`; maestros y atlas de 15 conjuntos.
- Fuentes v2: `assets/source/art/rest_poses_v2/`; maestros/atlas para los acostados.
  Los cuadros A con silla de v2 quedan sustituidos por A sin silla de v3.
- Se conservan PROMPTS, EXPORTACION, MANIFIESTO y VALIDACION originales como
  procedencia de cada entrega. Describen sus exportaciones originales; no son
  la validación de esta integración ni cambian la raíz assets/source/art.
- Las vistas generales y GIF de revisión quedan en los ZIP artísticos originales;
  no se duplican dentro del runtime. No se agregan README o TXT de arte a docs.

Estados y conexión de juego: SYSTEMS.md. El código conserva las escalas de cada
actor. Sentado/acostado no activa por sí mismo curación, cámara ni calendario.

## Audio de interfaz vigente

| Acción | Recurso o alias | Tratamiento |
| --- | --- | --- |
| Abrir y avanzar diálogo | `caelum/ui/dialogue_open` → `sounds/caelum/ui/ca_dialogue_open.ogg` | Primera frase de `ca_stock_tarot_harp_loop.ogg`: 113.400 muestras a 44.100 Hz (2,571429 s), estéreo, Vorbis q5; caída de 450 ms hasta silencio. GameInfo.ChatSound es el único emisor; singular evita apilar frases al avanzar rápido. |
| Portada / menú antes de comenzar | `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Stock completo de 6 s; una reproducción, sin bucle, por entrada a la portada. |
| Abrir/cerrar/volver/pregunta de menú | `caelum/ui/menu_open` | Redirecciones nativas activate, backup, prompt, dismiss y clear. |
| Mover/cambiar opción | `caelum/ui/menu_move` | cursor, change e invalid. |
| Confirmar/avanzar | `caelum/ui/menu_select` | choose y advance. |
| Salir del juego | `caelum/stock/menu_strings_start` | CaelumExitMenu reproduce la pieza al abrir la confirmación nativa. QuitSound y los alias quedan como cobertura de salida; singular evita superposición. Stock de 4,0222 s sin recortar. |
| Interruptor de mapa | `caelum/ui/menu_select` | switches/normbutn. |
| Botón Exit de mapa | `caelum/stock/menu_strings_start` | switches/exitbutn. |

La música de MAP01 conserva CA_MUS01 y la de MAP02 CA_MUS02. Abrir el menú
de pausa durante una partida conserva la música de ese mapa. El original del
arpa se conserva íntegro; el recorte es otro archivo. No se importan sonidos Doom.

### Asignaciones y emblemas vigentes (4.33.0j)

Por pedido del autor, TitleMusic apunta al War Drums completo de 6 s. El
observador ahora pide reproducción sin bucle; los mapas conservan CA_MUS01/02.
QuitSound y menu/quit1, menu/quit2, switches/exitbutn usan menu_strings_start.
No se recodifican ni recortan estos archivos. La frase de arpa de 2,571 s y la
protección singular de conversación permanecen como en 0h.

Las cuatro runas de Caella reutilizan los emblemas de Sellos SLWA, SLFI, SLEA y
SLAI a escala 0,20, con opacidad de estado. Su presentación del
acertijo quedó aceptada con las pruebas de 0k. En 0m las cuatro permanecen
encendidas tras resolverlas y la pared conserva su textura CMIN01 al habilitar el paso.

## Modelos sencillos de estaciones (4.33.0j)

Aceptados por el autor en 0j. La revisión 0m conserva todos sus archivos,
texturas y asociaciones; tampoco modifica el HUD aceptado ni el audio.
La limpieza de salas retira instancias del surtido, no recursos gráficos.


Doce OBJ originales, con once texturas compartidas de 128×128, derivados por
geometría procedural de los rasgos de los doce sprites existentes. No se usan
modelos externos ni sprites planos como sustituto de herramientas 3D.
`src/models/caelum/props/stations/` contiene sólo recursos de ejecución.
`assets/generators/generate_station_models.py` conserva la fuente y reutiliza
las primitivas de los generadores ambientales y de cofres (Python + Pillow).

| Estación | Silueta y elementos |
| --- | --- |
| Banco de trabajo | Mesa, tornillo de banco, martillo, formón y vela. |
| Forja | Hogar de mampostería con carbón, chimenea y pala; sin mesa. |
| Yunque | Yunque de hierro, cuerno y martillo sobre tocón; sin mesa. |
| Taller de distancia | Mesa, arcos, flechas, herramienta y plantilla. |
| Aserradero | Banco con sierra circular manual, manivela, tronco y tablones. |
| Taller de armaduras | Mesa, peto sobre soporte, cuero y martillo. |
| Máquina de coser | Mesa con máquina, volante, aguja, carrete y tela. |
| Altar de esencias | Pedestal de piedra, cristal, aro, velas y libro. |
| Globo terráqueo | Globo sobre pie propio con aros de latón y mapa esquemático. |
| Banco joyero | Mesa, gemas, lupa de soporte, útiles y vela. |
| Herramientas finas | Mesa con paño, estuche abierto, lupa y herramientas. |
| Banco maestro | Mesa con cajones, panel de herramientas, plano, libro y tornillo. |

MODELDEF contiene doce modelos y un enlace adicional del alias antiguo
CaelumBowWorkshopStation al modelo de distancia. Mantiene los sprites como
alternativa si el motor desactiva modelos. La escala compensa el Scale 0.5
existente; todas las mallas caben en Radius 20 / Height 48. No cambia actores,
recetas, capacidades, proximidad de red ni tiempos de crafting.

Para regenerar desde la raíz: `python assets/generators/generate_station_models.py`.
El bloque generado de MODELDEF se reemplaza de forma idempotente. Las texturas
son propias del generador; los sprites de referencia conservan sus archivos y
su procedencia. No se añaden dependencias al constructor ni al juego.

El indicador del Sello reutiliza su icono existente, incluido el tier, y aplica
la desaturación nativa al dibujarlo. No guarda otra copia del icono ni modifica
sus píxeles. Se verifica con el renderizador OpenGL moderno de GZDoom 4.14.2.

## Atribuciones de los recursos de interfaz

- Simple Harp Loop: Roloxi, Freesound #639113, CC BY 4.0. Se documentan el
  fragmento musical, el fundido y la recodificación en el registro redistributivo.
- lovelyboot1.ogg / menu_strings_start: pizzaiolo, Freesound #320664; conservar
  también la atribución a humphreyswill, KorgStrings001.aif #61109, CC BY 4.0.
  El archivo ya aprobado se usa sin modificar sus bytes.

La atribución completa, URLs y licencias permanecen en
[AUDIO_PACK_04_CREDITS.md](../src/licenses/AUDIO_PACK_04_CREDITS.md),
[AUDIO_CREDITS.md](../src/licenses/AUDIO_CREDITS.md) y
[AUDIO_PACK_05_CREDITS.md](../src/licenses/AUDIO_PACK_05_CREDITS.md).
No se reescribe la licencia de un tercero al reorganizar documentos.

## Inventario físico de audio

El proyecto completo auditado contiene 74 archivos de runtime: 72 OGG y 2 MP3, incluido
el nuevo recorte. El paquete 05 conserva 10 archivos de reserva externa que
no se añaden a src. Total catalogado: 84 archivos. Una copia por otro nombre
no implica otra grabación: menu_move y menu_select siguen compartiendo contenido.
Los 14 alias nativos de interfaz/interruptores tampoco añaden archivos.

Las rutas siguientes son relativas a src. La tabla registra recursos; la
existencia de un archivo no implica que ya exista un emisor de clima o escena.

| Archivo | Asignación |
| --- | --- |
| `music/CA_MUS01.mp3` | Música de MAP01. |
| `music/CA_MUS02.mp3` | Música de MAP02. |
| `sounds/caelum/ambience/ca_ambience_blacksmith_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_crowd_murmur_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fire_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fountain_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_rio_waves_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_sewer_water_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/enemies/mandinga/ca_mandinga_alert.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/enemies/zupay/ca_zupay_alert.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/enemies/zupay/ca_zupay_walk.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/ca_item_pickup.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/ca_weapon_pickup.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_01.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_02.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_03.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_04.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_05.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_06.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_07.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_08.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_09.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_10.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_11.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_12.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/npcs/palomo/ca_palomo_disappear.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/npcs/rulo/ca_rulo_alert.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/anima/ca_anima_restored.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/ca_low_health_heartbeat.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/ca_footstep_grass.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_01.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_02.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_03.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_04.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_05.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_06.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_07.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_08.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/movement/ca_swim_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/progression/ca_level_up.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/player/status/ca_player_cough.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/stock/ambient/ca_stock_cricket.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/music/ca_stock_piano_progression.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/music/ca_stock_tarot_harp_loop.ogg` | Original de arpa conservado; fuente del recorte. |
| `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Música de portada, una sola reproducción (6 s). |
| `sounds/caelum/stock/ui/ca_stock_menu_strings_start.ogg` | Salir del juego y botón Exit de mapa (4,022 s). |
| `sounds/caelum/stock/ui/ca_stock_reveal_sting.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/voices/ca_stock_evil_laugh.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/voices/ca_stock_ghoul_laugh.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/voices/ca_stock_npc_mumble_male.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/stock/world/ca_stock_iron_gate.ogg` | Reserva sin evento narrativo asignado. |
| `sounds/caelum/ui/ca_crafting_page_turn.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/ui/ca_dialogue_open.ogg` | Apertura y avance de conversaciones, primera frase de 2,571429 s. |
| `sounds/caelum/ui/ca_map_transition.ogg` | Prólogo, transición y Exit. |
| `sounds/caelum/ui/ca_menu_move.ogg` | Movimiento/cambio de opciones. |
| `sounds/caelum/ui/ca_menu_open.ogg` | Apertura/cierre y navegación de retorno. |
| `sounds/caelum/ui/ca_menu_select.ogg` | Confirmar/avanzar e interruptores normales. |
| `sounds/caelum/ui/ca_recipe_learned.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weapons/ca_carabine_fire.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_heavy_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_light_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_soft_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_steady_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_distant_01.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_heavy_01.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_roomy_01.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/weather/ca_weather_wind_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/doors/ca_door_large_open.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/doors/ca_door_locked.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/doors/ca_door_open.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/fire/ca_fire_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/seals/ca_quintessence_seal_activate.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/seals/ca_quintessence_seal_deactivate.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |
| `sounds/caelum/world/weather/ca_rain_loop.ogg` | Registrado; uso según llamadas de actor, sistema o TERRAIN. |

### Reserva externa del paquete 05

| Archivo | Obra / autor | Uso propuesto, aún no asignado |
| --- | --- | --- |
| `sounds/stock/music/ca_stock_piano_short_loop_01.ogg` | Piano short loop — Roloxi | Piano diegético de salón, fonda o mansión; confirmar encaje tonal antes de asignar. |
| `sounds/stock/horror/ca_stock_breath_stinger_01.ogg` | breath stinger1 — Tissman | Proximidad espectral, maldición o drenaje de ánima; no sustituye la señal de vida baja ya elegida. |
| `sounds/stock/reactions/ca_stock_slow_clap_01.ogg` | man claping slow — Wicopee | Aplauso lento teatral para Palomo, Mandinga, una audiencia o una cinemática. |
| `sounds/stock/voices_en/ca_stock_demonic_you_died_en.ogg` | you died.ogg — nfsmaster821 | Voz demoníaca en inglés; reservar para prototipo o criatura que canónicamente hable inglés. |
| `sounds/stock/props/ca_stock_toilet_flush_01.ogg` | Toilet Flush — andersmmg | Descarga o cisterna; usar solo si el artefacto sanitario es coherente con la localización y época. |
| `sounds/stock/music/ca_stock_piano_loop_02.ogg` | Piano loop — Roloxi | Piano de salón o mansión; mantener como música diegética hasta definir la escena. |
| `sounds/stock/music/ca_stock_creepy_piano_stinger_01.ogg` | Terrible Piano — TheFlakesMaster | Piano inquietante para mansión embrujada, presagio o descubrimiento. |
| `sounds/stock/creatures/ca_stock_monster_scream_01.ogg` | Monster Scream - V2 — Roloxi (adaptación); Thanra (fuente CC0) | Grito de monstruo genérico o élite; no asignar a una criatura nombrada sin probar identidad y mezcla. |
| `sounds/stock/ui/ca_stock_triumph_jingle_01.ogg` | Triumph (jingle) — lightbulbafagd | Logro, misión completada o aumento de reputación; no reemplaza el sonido de receta ya elegido. |
| `sounds/stock/music/ca_stock_dark_chords_01.ogg` | Dark Chords — Scrampunk | Presagio, ritual o transición oscura. Es sintetizado, por eso no se integra automáticamente con la preferencia instrumental del proyecto. |


## Primera persona: referencia de espada aceptada

### Alcance

La vista modular continúa conectada exclusivamente con
`CaelumSwordSelectorWeapon`, la espada real equipada desde el Inventario. No
existe un arma especial de prueba ni una segunda ruta de daño o bloqueo.

El autor completó con éxito toda la matriz de `PRUEBAS_4_32_0o.txt`; por ello
esta composición queda cerrada como referencia. Más adelante se aplicará el
mismo enfoque modular a todas las armas, con arte y movimiento propios de cada
familia. La ampliación a las demás armas sigue pendiente y no reabre las pruebas
ya aceptadas de la espada.

V4.32.0o conserva la altura, el pulgar completo y la trayectoria de V4.32.0n,
pero corrige el cuadro que mostraba dos puños. El código anterior calculó los
pivotes con el tamaño completo del PNG; GZDoom aplica `PSPF_PIVOTPERCENT` a la
caja visible de cada textura. Como `RHND`, `DSWD` y `RFNG` tienen cajas alfa
distintas, las dos representaciones complementarias de la misma mano se
separaban al girar. Los nuevos porcentajes compensan esas cajas y hacen que
las tres transformaciones resuelvan al pivote real ya usado por la espada.
No modifica sprites, daño, Aire, enfriamiento, durabilidad, sonidos,
persistencia, equipo, HUD, mapas, economía, Palomo ni diálogos.

### Encuadre por estado

| Estado | Escudo (10) | Mano izquierda (20) | Mano/dedos derechos (25/40) | Espada (30) |
| --- | ---: | ---: | ---: | ---: |
| Reposo | X=82, Y=45 | X=82, Y=45 | X=282, Y=32 | X=260, Y=0 |
| Block sostenido | X=160, Y=100 | X=160, Y=100 | Ocultas | Oculta |

En reposo, escudo y mano izquierda continúan juntos en la marca inferior
izquierda aceptada. La palma y el pulgar derechos permanecen en (282,32). La
espada pasa de (260,4) a (260,0), por lo que sube ligeramente sin cambiar su
registro horizontal aprobado.

### Block frontal, cercano y sostenido

El Block no cambia respecto de V4.32.0m. H sigue siendo una transición breve
de tres tics e I usa duración `-1`, fija hasta terminar el estado real de
Block. El escudo y su mano correcta permanecen en las capas 10 y 20 a
(160,100); las capas de la mano hábil 25/30/40 se limpian para evitar una
segunda mano. Al soltar Block, el conjunto derecho se reconstruye de inmediato.

La exportación `DSHDI0` conserva 450×300, `grAb (225,48)` y una caja visible
de 293×244. `LHNDI0` comparte lienzo y origen y conserva su caja visible de
213×169. No cambian perspectiva, tamaño, altura ni condición de equipo.

### Pulgar completo delante del mango

`RFNGA0` y `RFNGB0` mantienen lienzo RGBA 320×200 y `grAb (160,32)`, pero la
máscara frontal ahora incluye todo el pulgar visible que ya existe en la capa
de mano `RHND`. La ampliación A añade exactamente 443 píxeles visibles con el
color original de Domingo: 413 conservan también su alfa exacto y 30 reducen
sólo el alfa en el borde suavizado de la máscara. No repinta ni desplaza ningún
píxel que ya pertenecía a `RFNG`. B es la misma pose desplazada exactamente
(+1,+1), tal como ocurre entre `RHNDA0` y `RHNDB0`.

La caja alfa inclusiva pasa a (148,92)–(210,151) en A y
(149,93)–(211,152) en B. De este modo, el mango queda detrás del pulgar entero
y ya no parece cortar el dedo.

### Giro sincronizado sin duplicación

La espada conserva exactamente su pivote y movimiento aceptados. Para mano y
pulgar, los porcentajes se calculan sobre sus cajas alfa reales, no sobre el
lienzo transparente. El resultado de cada fila, después de compensar `grAb` y
el desplazamiento espada–mano (-22,-32), es el mismo punto de pantalla
(56.64375,84.57):

| Capa | Caja alfa A / tamaño | Pivote porcentual | Punto efectivo del PNG | Punto de pantalla común |
| ---: | --- | ---: | ---: | ---: |
| 25 `RHND` | (147,128)–(479,239) / 333×112 | (0.2091403904, 0.2550892857) | (216.64375,156.57) | (56.64375,84.57) |
| 30 `DSWD` | (168,0)–(294,178) / 127×179 | (0.55625, 0.83) | (238.64375,148.57) | (56.64375,84.57) |
| 40 `RFNG` | (148,92)–(210,151) / 63×60 | (1.0895833333, 0.4095) | (216.64375,116.57) | (56.64375,84.57) |

El X de `RFNG` supera 1 porque el punto compartido queda apenas fuera de su
caja visible; el motor permite pivotes porcentuales fuera del intervalo
0–1. La compensación mantiene los tres píxeles de anclaje coincidentes hasta
el máximo giro y elimina la silueta duplicada del puño.

La hoja conserva sus ángulos absolutos. La mano y el pulgar reciben solamente
la variación respecto del reposo: `rotación_mano = rotación_espada - 18°`.
Así, el arte de la mano no cambia en reposo y durante el ataque acompaña tanto
la posición como el giro de la espada sin perder el agarre.
El delta total de la mano va de 0→25° entre reposo e impacto.

| Momento | Hoja absoluta | Mano/pulgar | Ángulo visual aproximado |
| --- | ---: | ---: | ---: |
| Reposo | 18° | 0° | 79° |
| Salida 1 | 21° | 3° | 82° |
| Ápice | 24° | 6° | 85° |
| Barrido 1 | 31° | 13° | 92° |
| Barrido 2 | 38° | 20° | 99° |
| Impacto | 43° | 25° | 104° |
| Retorno 1 | 39° | 21° | 100° |
| Retorno 2 | 31° | 13° | 92° |
| Retorno 3 | 24° | 6° | 85° |
| Reposo recuperado | 18° | 0° | 79° |

Cada valor es absoluto y se reaplica durante la sincronización; no se acumula
entre tics.

### Curva de ataque y retorno recto

Los ocho tics continúan reutilizando la pose A. Cinco puntos llevan la mano
por la curva aprobada hasta el impacto y tres puntos colineales la devuelven en
línea recta. La espada mantiene en todo momento el registro constante
(-22,-32) respecto de la traslación de palma y pulgar:

| Tic | Fase | Mano/dedos X,Y | Espada X,Y | Hoja / mano |
| ---: | --- | ---: | ---: | ---: |
| 1 | Salida | (300,15) | (278,-17) | 21° / 3° |
| 2 | Ápice derecho | (318,-4) | (296,-36) | 24° / 6° |
| 3 | Barrido alto | (287,-1) | (265,-33) | 31° / 13° |
| 4 | Aproximación | (236,11) | (214,-21) | 38° / 20° |
| 5 | Impacto izquierdo | (201,21) | (179,-11) | 43° / 25° |
| 6 | Retorno 1 | (228,25) | (206,-7) | 39° / 21° |
| 7 | Retorno 2 | (255,28) | (233,-4) | 31° / 13° |
| 8 | Retorno 3 | (275,31) | (253,-1) | 24° / 6° |
| — | Reposo | (282,32) | (260,0) | 18° / 0° |

La subida uniforme de cuatro unidades afecta únicamente a la hoja; no altera
la curva de la mano ni el retorno recto ya aceptados.

### Manga panorámica, profundidad y equipo

`RHNDA0` y `RHNDB0` conservan los lienzos RGBA 480×240 con `grAb (160,72)`
aceptados en V4.32.0h. La manga llega al extremo derecho del lienzo y no revela
un corte interno en 16:9.

| Capa | Prefijo | Contenido | Regla |
| ---: | --- | --- | --- |
| 10 | `DSHD` | Reverso del escudo | Sólo con escudo válido equipado |
| 20 | `LHND` | Mano/brazo del escudo | Visible con el escudo, incluido Block |
| 25 | `RHND` | Antebrazo, palma y base del puño | Oculta en Block; detrás de la espada fuera de él |
| 30 | `DSWD` | Espada | Oculta en Block; atraviesa el agarre fuera de él |
| 40 | `RFNG` | Pulgar y dedos de cierre | Ocultos en Block; delante del mango fuera de él |

`HasActiveBlockSource()` continúa siendo la única condición visual del escudo.
Si se desequipa, se rompe o deja de ser compatible, `DSHD` y `LHND`
desaparecen en el siguiente tic. Sin escudo válido no se muestra el arte ni se
habilita Block.

### Estado de prueba

La auditoría automática comprueba estructura ZScript, delta acotado,
dimensiones RGBA, offsets `grAb`, cajas alfa, hashes, ampliación exacta del
pulgar, desplazamiento A→B, pivote de pantalla común, rotación sincronizada,
registro (-22,-32), Block correcto y contenido reproducible del ZIP fuente.
La matriz visual de `PRUEBAS_4_32_0o.txt` fue completada con éxito por el
autor. Esta composición queda aceptada como referencia cerrada. El delta 0h
no cambia sus archivos de arte, estados, trayectoria, daño ni Block.

## Iconos de equipo

Fuente autoral: `Caelum_Argenteum_tiers_2_3_argentinos_REHECHOS.zip`.

En 4.33.0d se incorporaron sus 99 PNG sin modificar sus bytes, dimensiones, proporciones,
transparencia ni nombres: 49 variantes T2, 49 variantes T3 y
`ca_giant_gauntlets.png` corregido. Incluye armas, armaduras, guantes, botas,
cascos, escudos, amuletos y sellos.

Destino: `src/graphics/caelum/icons/`, preservando `jewelry/`. El resolver de
iconos existente selecciona `_t2` y `_t3`; los archivos sustituyen sus versiones
anteriores en el inventario, equipo, comercio y menús que usan ese resolver.
No son cuadros del rig de manos/espada de primera persona.

Cada PNG es RGBA 128×128 y tiene alfa transparente y contenido visible. La
auditoría compara los 99 archivos contra los bytes del adjunto y contra el
runtime completo. El manifiesto y las instrucciones de autor se conservan en
`assets/source/art/tiers_2_3_rehechos_4_33_0d/`.

Los adornos T2/T3 argentinos y la pareja corregida de guanteletes reemplazan
los iconos anteriores. Estadísticas, valores, recetas, pesos y mecánicas no
dependen de esta importación gráfica.

## Tipografía y dirección artística

Argentina del siglo XIX, fantasía oscura semirrealista, tonos terrosos y
metálicos. Conservar la perspectiva del adorno, el Sol de Mayo y la insignia
según el lugar del equipo. La expansión de primera persona requiere arte y
movimiento propios para cada familia; los iconos no sustituyen esas animaciones.

Las funciones tipográficas son CaelumDisplay (títulos), CaelumText (lectura),
CaelumSmall (ayudas) y CaelumMono (contadores/depuración). Mantener celdas con
línea base común, cobertura de español y licencia DejaVu donde corresponda.
El menú principal usa texto real. GZDoom 4.14.2 fija NewSmallFont de los
OptionMenu desde gzdoom.pk3: el MENUDEF actual mejora espaciado, pero no se
debe declarar sustituida esa fuente sólo por incluir un alias.

## Trazabilidad y próximos assets

El antiguo ASSET_REGISTER y los registros tipográficos están íntegros en
HISTORY.md. Son inventarios fechados, no pruebas de que todos los assets
antiguos sigan en uso. Los avisos de distribución actuales siguen en
src/licenses. Los iconos T2/T3 incorporados en 0d están aceptados; continúan
pendientes las vistas de primera persona restantes y el contenido visual de
las futuras alcantarillas. No recuperar placeholders Doom al reconstruir paquetes.

## Fuentes y generadores después de la auditoría 4.33.0h

Los 20 archivos de `art_source/` pasan íntegros a `assets/source/art/`. Se
conservan nombres, subcarpetas y huellas: los originales de manos/escudo,
prompts e inventario de iconos documentan decisiones y permiten reeditar arte.
Las iteraciones rechazadas no se convierten por ello en recursos vigentes.
`assets/source/world/` conserva el atlas maestro ambiental; `assets/audio_stock/`
conserva el paquete 05, sus checksums y su procedencia. No se carga esa reserva
en el PK3 sin asignarle un uso.

Tres generadores reutilizables pasan de tools a `assets/generators/`:

| Generador | Utilidad y dependencia |
| --- | --- |
| generate_environment_models.py | Modelos/texturas de rocas y árboles y sus registros; Python 3 y Pillow. |
| generate_mineral_veins.py | Modelos/texturas y registros de vetas; Python 3, Pillow y el generador ambiental del mismo directorio. |
| generate_stash_models.py | Modelos y texturas de alijos; biblioteca estándar de Python 3. |

Sus rutas predeterminadas se resuelven desde el proyecto, incluso si se invocan
desde otra carpeta. `--help` muestra los destinos configurables. Generar recursos
es una operación de edición deliberada, independiente de compilar o jugar;
no se ejecutan generadores al aplicar el parche. El build sólo empaqueta src.
Las utilidades específicas de parches anteriores quedan en el respaldo histórico.

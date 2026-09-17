# Caelum Argenteum — Proyecto, estado y roadmap

Versión documental: 4.35.0q — 2026-09-17.

## Estado actual: 4.35.0q — sprites v4 y consumo sentado

Delta sobre el proyecto completo 4.35.0p, probado y aprobado por el autor.
El autor aporta Caelum_Argenteum_Sprites_Iconos_v4(1).zip y modifica únicamente
el ritmo de comida/bebida sentada: pasa de 1/10 a 1/3 del ritmo ordinario.
Cada porción completa tarda 30 segundos de simulación, conserva sus diez
pulsos y consume las mismas unidades/litros. Levantarse continúa a ritmo normal.

El paquete visual queda integrado en los estados actuales de nueve personajes:
respiración, carreras, caminatas de Domingo/Palomo/Mandinga/Zupay, poses de
descanso de Palomo, reemplazos del toro/Ronnie e íconos, incluida la bolsa.
Los nuevos estados se anexan para conservar los índices de guardados de 0p.
Palomo conserva sus diálogos y recorrido de salida; su pose responde al
movimiento real. El jugador conserva prioridad de agachado, ataque y descanso.

Los sistemas de viajes, reservas, calendario, vehículos y mapas de 0p quedan
aprobados. Para cerrar 4.35 resta la aceptación visual y del ritmo de 0q según
PRUEBAS_4_35_0q.txt; luego corresponde 4.36, peligros físicos.

## Base aprobada: 4.35.0p — reservas y primeros vehículos

Delta sobre 4.35.0o. El autor aprueba 0n/0o salvo los puntos corregidos aquí:
consumo sentado desde inventario/Caja y conflicto de Escape. Autoriza una
carreta cubierta y un pequeño mercante con velas y remos, con sus instalaciones
en ambos mapas costeros. El autor aprobó estos cambios al solicitar 0q.

La mesa busca primero sus raciones, luego las llevadas y finalmente las de la
Caja propia. Conserva el ritmo sentado aprobado, el volumen de las porciones,
la digestión y ambos toggles independientes. Se detiene al saciarse, agotarse
la reserva o levantarse. Los recipientes vacíos y pilas restantes no se extraen.
Q/B cancela el presupuesto y vuelve del calendario/detalle; Escape abre la
pausa nativa y permite regresar a la misma pantalla.

MAP06 y MAP07 tienen una carreta de carga cubierta dentro de un rancho. MAP06
conserva su puerto y agrega el mercante; MAP07 suma un muelle de madera y otro
mercante. Usar la carreta o el cartel de embarque abre el presupuesto del
recorrido de 500 km. Son servicios de prueba con conductor/tiro y guardias,
sin tarifa por ahora; no son vehículos de conducción libre.

Carreta: 3 km/h en movimiento, 16 h de marcha / 8 h de campamento. Mercante:
5 nudos (9,26 km/h), navegación continua con viento favorable; el pasajero
duerme durante la travesía. El calendario incluye sólo tiempo realmente
transcurrido; dormir a bordo no agrega una segunda vez esas horas.
Las velocidades y dimensiones son valores nominales representativos de diseño,
no mediciones de una carreta o nave argentina histórica individual.

Las estructuras y vehículos se instalan una vez al entrar/cargar, también
sobre mapas guardados con 0o, y se conservan en el hub. La confirmación exige
seguir cerca del mismo vehículo y recalcula las provisiones antes de salir.

### Cierre vigente de 4.35

Queda la prueba manual de 0p: reservas de mesa/Caja, Q y Escape, entrada del
rancho, embarque, proporciones visuales y viaje por cada vehículo. Si no surgen
fallos, se puede cerrar 4.35 y continuar con 4.36 (peligros físicos). No hace
falta repetir las pruebas de 0n/0o ya aprobadas ni agregar más mapas o asedios.

## Base entregada: 4.35.0o — agenda y eventos persistentes

Delta sobre el proyecto completo 4.35.0n. El autor define los eventos:
asedios, rutinas de NPC/misiones secundarias, alquileres, envíos de mercancías,
crecimiento de vetas y futuras categorías. Pide un calendario con sus fechas.
0n y 0o fueron probados por el autor; 0p resuelve las observaciones recibidas.

TAB → Mundo → F/RT abre el calendario mensual de campaña. Señala hoy, la
selección y cuántas series conocidas caen en cada día; muestra hora, tipo y
ocurrencia registrada/programada. Detalle ofrece estado de la serie, primera y
próxima fecha, intervalo y contador. Los eventos desconocidos no se revelan.
La fecha de depuración del clima no desplaza esta agenda.

El registro persistente calcula las ocurrencias vencidas sin reproducir miles
de tics de IA. Se conecta al reloj ordinario, Limbo 1:1, descanso, x105 y viajes
confirmados; una consulta de presupuesto no dispara eventos futuros. Guardado
y carga conservan fechas, contadores, cancelación, deuda y cargas retiradas.

Adaptadores concretos: fases de asedio que interrumpen descanso/aceleración;
NPC de ensayo que cambia de destino según su rutina; vencimiento de objetivos
incompletos de una misión; alquileres con deuda/pago manual en monedas reales;
carga de materiales retirada al despachar y recuperable una vez en destino;
recuperación de recursos que cuenta también la ausencia de su mapa. Los
recursos mantienen 0,1 % de capacidad por día de campaña, sin rebalancearlos.

Los ensayos son voluntarios por consola. No se inventan alquileres de campaña,
precios, horarios de los cuatro residentes ni envíos comerciales canónicos.
La infraestructura admite esos contratos cuando un mapa/misión los registre.
El asedio de ensayo prueba fases y bloqueo temporal; el director de batallas,
ejércitos y consecuencias políticas conserva su alcance V5 ya acordado.

### Cierre de 4.35

La implementación temporal de este bloque queda candidata a cierre. Faltan la
aceptación manual del autor de los cambios de 0q y resolver cualquier fallo que aparezca.
No se exige nuevo contenido de campaña ni repetir las pruebas ya aprobadas.
Después siguen 4.36 (peligros físicos), 4.37 (Tarot/Trucazo), exportación V4,
reorganización V5.0 y exposición térmica V5.1.

## Base entregada: 4.35.0n — viajes medidos y provisiones

Delta sobre el proyecto completo 4.35.0m. El autor aprueba las pruebas de
raciones de alimento y los mapas. Define 10 km entre depósito de alcantarillas
y puerto, y 500 km entre puerto y playa, con jornadas de 16 horas caminando y
8 durmiendo, velocidad actual del personaje y consumo de sus provisiones.

El acceso muestra presupuesto antes de salir: velocidad real convertida a
km/h, duración de marcha/sueño, raciones necesarias/llevadas/a consumir, agua
adicional en recipientes y reservas/salud previstas al llegar. Enter confirma;
Q/B cancela sin descontar raciones ni adelantar el reloj por el trayecto.
El mundo sigue su paso normal mientras se lee. Si cambian velocidad, consumo,
existencias o riesgo mortal, se actualiza la vista antes de una nueva confirmación.

La velocidad se mide como marcha sostenida sobre suelo normal, 32 MU/m. Se
fija al partir, sin añadir pausas por animación ni reducir la distancia por el
factor 20:1 del calendario. No se agrega una noche si ya se llegó al destino.
La caravana diagnóstica sigue siendo marcha a pie, sin vehículo ni nueva tarifa.
Los accesos interiores MAP02–05 conservan su tratamiento local sin distancia
asignada. Sólo las cuatro conexiones dirigidas 8–11 tienen presupuesto temporal.

La simulación numérica de un tic aplica necesidades, digestión, regeneración,
lucidez y sueño. Usa bolsa propia si se lleva, suelo en otro caso; no crea
raciones, recipientes, muebles o comodidad. Bebe primero raciones de agua y
luego litros de recipientes; no gasta pertenencias de la Caja. No empieza a
comer/beber dormido. Las porciones empezadas continúan sus pulsos al llegar.
Una previsión mortal exige confirmación visible y termina con muerte nativa
en origen sin acreditar llegada; no se exige comprar provisiones para salir.

El trayecto se aplica atómicamente: un descuento, un intervalo del reloj,
registro persistente, clima a la fecha de llegada y cambio de mapa. Se conserva
el presupuesto al guardar; siempre se revalida antes de cobrar. No se simulan
IA, física o encuentros del mapa de salida durante esas horas. Los efectos
activos y el combate deben terminar antes del viaje. Límite técnico visible:
30 días de marcha por presupuesto; no se truncan rutas mayores.

## Base entregada: 4.35.0m — comida por masa y costa

Comida/agua aportan 800/masa corporal en kg puntos por ración. Se integraron
18 materiales del autor, MAP06 puerto y MAP07 costa, sus conexiones nativas,
refugios de dos sillas, cobertura física, río no potable y clima de Buenos
Aires confirmado en MAP02–07. Sus pruebas de comida y mapas están aprobadas.

## Base entregada: 4.35.0l — sillas, agua y clima regional

El autor aprueba 0j y 0k; de 0i sólo observa la segunda silla de Ronnie y
Argento. Este delta se aplica sobre el proyecto completo 4.35.0k.

La silla existía, pero quedaba detrás de una pared sobre otro sector con la
misma altura de piso. Las mesas 102/104 pasan a (1072, ±480, 136), orientación
0°, con dos sillas visibles y utilizables. Se conservan camas, accesos, actores
originales, contenido y referencias. Un guardado sentado espera a levantarse
antes de mover su conjunto. La preparación recupera una silla ausente.

La ración de agua representa 0,16 litros y pesa 0,16 kg. Restaura diez puntos
de Sed en el cuerpo M base de 80 kg; conserva el escalado por masa corporal:
800/masa puntos por ración (8 puntos a 100 kg). El talle de ropa M admite
varias masas y no convierte a todos sus usuarios en cuerpos idénticos. Se
actualizan carga, Caja, comercio y consumo desde una regla de peso común.
Sentado conserva diez pulsos durante 100 s de simulación, frente a 10 s de pie.
Los recipientes continúan usando sus litros efectivos. Un efecto ya activo en
un guardado conserva la dosis con la que comenzó.

El clima usa normales mensuales contemporáneas del SMN, período 1991–2020
(publicadas en 2023; viento 2011–2020), para nueve estaciones. La fecha histórica
de campaña selecciona época del año y hora sobre esa referencia moderna. No se
reconstruyen observaciones de 1889 ni se consulta el pronóstico en cada partida.
Los episodios concretos de lluvia, nubosidad y frentes son síntesis reproducible;
los factores de cobertura son aproximaciones explícitas, no mediciones del SMN.

Confirmación posterior en 0m: MAP02–05 y los siguientes son de Buenos Aires.
Buenos Aires Observatorio es su referencia compartida; un marcador permite
elegir otras regiones en contenido futuro. MAP01 mantiene su excepción de Limbo:
20 °C, 55% HR, sin viento ni precipitación, con reloj 1:1 aprobado.

Los techos se detectan por trazas geométricas, incluidos pisos 3D. La muestra
local distingue exterior, techado abierto, interior y subsuelo; responde al
movimiento sin esperar al siguiente minuto climático. Las superficies de cielo
no cuentan como techo. Precipitación directa se anula bajo cobertura; la
humedad relativa se recalcula según temperatura/presión de vapor y humedad del
subsuelo. El viento cambia con región/frentes y disminuye bajo refugio.

El Diario informa región de referencia y cobertura. Se conservan semilla,
calendario, pausa y el mismo resultado a ritmo normal/x105. Ver SYSTEMS.md para
fuentes, fórmulas, límites y comandos; PRUEBAS_4_35_0l.txt para la aceptación
manual. Exposición corporal, ropa mojada y daño térmico siguen en V5.1.

Para cerrar 4.35 restan eventos y viajes con duración, integración conjunta y
aceptación de esos incrementos. Luego siguen 4.36, 4.37, exportación de pruebas
y V5.0/V5.1 en el orden acordado.

## Base entregada: 4.35.0j — ritmo local, interacción y áreas de clase

Delta sobre el proyecto completo 4.35.0i. El autor confirma la recuperación de
Sueño de 100 puntos por 8 horas de juego, la bolsa de 2 kg y el coste base de
Sueño del arcanista de 1000 Ánima. Solicita equiparar el radio de las habilidades
de clase con el radio base de canalización de los sellos: 1280 MU (40 m a la
escala de desarrollo). Sueño, única habilidad de clase implementada, usa esa
base común y el modificador de alcance existente. Las otras habilidades siguen
pendientes en V5; su futura área parte de la misma regla.

Comer/beber sentado reparte el mismo efecto y consumo durante 30 segundos de
simulación en vez de 10 (ajuste 0q del divisor 10 introducido en 0j). No cambia el total por ración ni los litros por sorbo.
La repetición automática espera a terminar cada porción; levantarse devuelve
los pulsos restantes al ritmo ordinario. Digestión, topes y comodidad conservan
sus reglas. La bolsa, las posiciones de 0i y el diseño aceptado se mantienen.

El Limbo pasa de calendario detenido a tiempo 1:1 durante juego activo a ritmo
normal. Reloj y fecha avanzan; necesidades por hora y recuperación de Sueño usan
horas locales. Afuera sigue 1 hora de juego por 180 segundos. T acelera el ritmo
local y los sistemas compatibles sólo durante descanso/fabricación válidos.
Pausa nativa detiene el tiempo; no se reconstruye tiempo de sesiones anteriores
ni tiempo con el juego cerrado. Palomo lo compara con otro lugar que él conoce.

Use comprueba la dirección de la mirada para muebles, mesas, residentes y
estaciones. Una estación rechazada, incluso en otra planta, ya no corta el
recorrido nativo de Use. Las estaciones quedan al 75% de 0i, es decir, al 150%
de antes de 0h: radio 30, altura 72 y escala 0,75. La migración es absoluta,
conserva los actores, sus redes, reservas y tareas; no vuelve a multiplicar.

Verificado en GZDoom 4.14.2/Linux: comidas lentas y automáticas, litros/digestión,
guardado/carga, reloj local y paridad con x105, sueño acelerado guardado de 0i,
fabricación, diálogos/puertas/muebles mediante Use nativo, 38 estaciones migradas,
límites de área y modificador. Capturas de Palomo y talleres revisadas. Falta
aceptación manual en Windows, incluida la del parche 0i; no se da por realizada.
PRUEBAS_4_35_0j.txt reúne la comprobación pendiente.

Para pasar a 4.36 falta completar el bloque 4.35: clima local (temperatura,
viento, precipitación y humedad), eventos programados/viajes temporizados,
adaptadores al reloj e integración. Después: 4.36 peligros físicos, 4.37
Tarot/Trucazo, exportación de prueba, V5.0 reorganización y V5.1 exposición térmica.
No hay un número cerrado de parches restantes. Las secciones por versión que
siguen describen sus entregas históricas; esta sección fija el estado vigente.

## Base entregada: 4.35.0i — accesos, platos y avance en Limbo

El autor conserva el diseño de comida/agua y reporta seis incidencias de 0h.
Este delta sobre 0h corrige la altura de las figuras, intercambia las zonas de
cama/mesa de Ronnie y Argento, mueve la mesa de la sala del fondo 100 MU al este,
libera la puerta oriental del taller nordeste y asegura el muñeco de Rulo.

T queda dedicado al avance durante descanso/fabricación; el antiguo +10 minutos
de depuración se mantiene sólo por consola. El Limbo permite acelerar recursos,
descanso, consumibles y fabricación sin avanzar reloj ni calendario. Conserva
las sesiones de muebles sin duración y las guardas de actividad y peligro.

La migración reutiliza muebles, sillas, objetos y estaciones. Si un dormitorio
afectado está ocupado, espera a levantarse; reintenta si el destino está bloqueado.
Los guardados con el marcador antiguo del muñeco pero sin actor recuperan uno,
sin reiniciar la misión ni conceder ejercicios o recompensas.

Pruebas nativas en GZDoom 4.14.2/Linux: 26 asientos/4 camas, 38 estaciones,
paso real por puertas afectadas, blanco y registro de práctica, comparación
exacta de 105 tics normales/acelerados en Limbo, fabricación y carga de dormitorio
ocupado de 0h. Capturas revisadas. Controles Windows/recorrido completo en TXT.

## Base entregada: 4.35.0h — comidas y mobiliario de la mansión

El autor aprueba 0g, incluida la orientación. Se aplica este delta sobre esa
base. Comer resta Sueño equivalente a Hambre efectivamente recuperada / 4;
el coste se limita al máximo real y no se aplica a beber. F/G activa o detiene
por separado la repetición de comida/agua del tablero hasta saciarse. La porción
actual termina normalmente; levantarse cancela las próximas. No reinicia por
la pérdida pasiva posterior. El estado y las pertenencias se guardan.

Capacidades: 4 objetos en mesa de 2 plazas, 18 en la de 6 y 60 en la de 12.
Platos originales con comida y tazas representan las pertenencias reales.
Cada dormitorio de Rulo/Ronnie/Caella/Argento recibe cama y mesa de 2 sillas.
Hay una mesa de 6 en la sala de pared falsa/cueva y una de 12 en el segundo piso.

Todas las estaciones duplican sus dimensiones visuales y físicas. Las 26 de
los dormitorios se trasladan a los talleres de planta baja bajo cada habitación;
las 12 del segundo piso se conservan. Redes y especialidades permanecen
conectadas y separadas por sala; diálogos y direcciones se actualizan.

Para utilizar esos muebles en MAP01 se ofrecen sesiones sin duración, hasta
levantarse. Continúa la simulación personal; no se mueve el reloj del Limbo ni
se permite T. Las duraciones exteriores, comodidad, Lucidez y orientación de
0g se conservan. No se implementa Trucazo ni se modifica geometría WAD.

Comprobado con GZDoom 4.14.2 en Linux: digestión y límites, secuencias de comida,
capacidades, persistencia, uso de los 26 asientos y 4 camas de la mansión,
volumen de estaciones y redes, menús USDF y reloj detenido. Capturas revisadas.
El TXT 0h incluye controles y recorrido para aceptación en Windows.

## Base aceptada: 4.35.0g — avance seguro, mesas y sueño

El autor aprueba las pruebas de 0f y autoriza el siguiente parche. Se implementa
avance opcional con T únicamente al descansar/dormir o fabricar activamente, en
zonas de prueba seguras. Comparte pasos de reloj, recursos, efectos y fabricación;
no depende de i_timescale. Completar, cancelar o perder validez corta el avance.
El Limbo conserva tiempo detenido. El alcance general de clima, rutas y eventos
sigue pendiente de adaptadores al mismo servicio temporal.

MAP03 recibe mesa redonda para 2, rectangular 192×96 para 6 y grande 384×192 para
12; la grande duplica ambas dimensiones. Todas las sillas permiten Esperar. Use
coloca/retira pertenencias reales y F/G come/bebe sentado junto a la mesa. Se
preservan recipientes parciales y contenido al guardar. Referencias mesa/sillas
preparan el requisito futuro de Trucazo, sin implementar aún el juego.

Dormir reduce Lucidez 10/s y bloquea su recuperación. El aturdimiento por Lucidez
no lo corta. Arcanista User4 aplica Sueño de área con la misma lógica, duración
10 s, golpe despierta, reutilización 60 s y coste base provisional 1000 Ánima.
El radio de ensayo reutiliza 128 MU y el modificador de área existente. Las otras
habilidades continúan en V5. No cambia el bloque aprobado de atributos.

Se corrigen orientación de muebles y orden inverso de las vistas laterales del
atlas sin retocar PNG. GZDoom 4.14.2 en Linux compila y verifica tasas nativas
frente a aceleradas, las 20 sillas, consumibles, USDF, fabricación, habilidad y
guardados activos. Las capturas verifican costados y espalda. PRUEBAS_4_35_0g.txt
recoge instalación, controles, reservas críticas y comprobación de Windows.

## Base aceptada: 4.35.0f — bolsa de dormir y comodidad

El autor aprueba todas las pruebas de 0e. Solicita una bolsa de dormir que pueda
llevarse en el inventario y define tres factores de descanso: silla ×2, bolsa
×3 y cama/catre ×4 para recuperar Salud/Aire, con pérdida de Hambre/Sed dividida
por el mismo factor. Se implementan en este delta sobre 0e. El descanso sobre
suelo conserva ×1. Esperar sentado no recupera Sueño; dormir conserva la tasa
provisional anterior, sin multiplicarla por el soporte.

La bolsa es un Inventory nativo reutilizable de peso provisional 2 kg. Figura
en Todos y Llaves/objetos clave; Enter/A abre las duraciones, C la guarda/retira
de la Caja y D la suelta, con los controles existentes. Si estaba en la Caja,
Enter primero la retira. Elegir una duración despliega su modelo sobre suelo
seco, libre y nivelado; cerrar no despliega nada. El mismo objeto permanece
en el inventario durante la sesión y se recoge visualmente al levantarse,
completar o interrumpir, sin copias ni consumo.

Una preparación voluntaria de Mundo > D/X entrega una bolsa de prueba en
MAP02–MAP05; ca_debug_rest_bag ofrece la misma operación. No se concede al
cargar, al viajar ni al entrar al mapa. Tenerla impide recibir otra por esta
preparación. La recogida respeta capacidad y espacio en la Caja. No se agregan
recetas, precios, botín permanente ni nuevas categorías de navegación.

La comodidad aplica a la regeneración natural y al gasto por tiempo. El
consumo de Hambre/Sed incluye tanto su pérdida pasiva como los costes de curar
y recuperar aire. Se conservan máximos, acumulador fraccional de curación y
bloqueos por reservas críticas. Ánima, Lucidez y pulsos de consumibles no ganan
bonificaciones. La devolución de aire pendiente tras inmersión también se acelera por el
factor activo; fuera del descanso conserva sus tres segundos de base.

Se verificaron dentro de GZDoom 4.14.2 en Linux las tasas ×1/×2/×3/×4, la ruta
de activación de inventario y respuesta USDF, recogida/soltado/Caja, suelo
bloqueado, cancelación, daño, máximos y reservas críticas. Se cargó una sesión
en bolsa y un save anterior de 0e en catre, que recibió ×4 conservando su
progreso. El ensayo de bolsa y su continuación tras cargar finalizaron sin fallos;
parte del contador de comprobaciones se conserva desde antes del guardado. Las capturas
nativas muestran bolsa, postura y factor. El TXT cubre los controles físicos
y el recorrido del hub que debe comprobar el autor en Windows.

### Propuesta temporal de 0f adoptada en 0g

El contrato de avance propio por subpasos se implementa ahora con alcance
inicial seguro. SYSTEMS describe exactamente sus adaptadores y límites.

## Base aceptada: 4.35.0e — sillas, catres y cámara de descanso

El autor confirma que todas las pruebas de 0d1 dieron correctas y autoriza
el siguiente parche. Se considera aceptada la base de descanso de 0d reparada
por 0d1. Este delta agrega una silla y un catre utilizables en cada alcantarilla
MAP02–MAP05. Aparecen también al cargar un guardado anterior; una preparación
repetida conserva la pareja existente. No se modifican los WAD ni se crea una
ruta de regreso a MAP01.

Usar la silla abre Esperar; usar el catre abre Dormir. Se elige entre 5 minutos,
1, 4 u 8 horas de juego. El inicio ocurre después de cerrar la respuesta y
validar alcance, suelo y espacio. Cerrar sin elegir deja al personaje de pie.
TAB > Mundo > D/X conserva el descanso sobre suelo y sus preparaciones
voluntarias. No se otorgan recursos al acercarse, abrir, cargar o viajar.

La cámara de tercera persona permite observar las poses existentes y orbitar
con los controles de mirar. Usa el recorte nativo del motor contra el entorno.
Q/B, movimiento o acción levantan al personaje; TAB lo levanta y abre el Diario;
Escape conserva la pausa. Al finalizar/interrumpir se libera el mueble y la
cámara y se recupera la dirección de entrada. Se busca una salida libre sin
telefrag; si las salidas están ocupadas, el mueble deja salir caminando antes
de recuperar su colisión. Se conservan altura/radio físicos del jugador.

Dormir mantiene la recuperación provisional de Sueño de 100% por 8 horas de
juego. Esperar, Hambre, Sed y regeneración conservan sus tasas aprobadas.
La fecha inicial sigue siendo 03/11/1889 09:00; MAP01 detiene el reloj y los
demás mapas avanzan al ritmo común de 1 hora de juego por 180 segundos reales.
Este incremento no acelera el tiempo. Las habilidades acordadas siguen
registradas para su bloque posterior, sin introducirlas en el descanso.

Verificación: compilación con GZDoom 4.14.2 y pruebas nativas automáticas en
Linux para interacción Use/USDF, uso repetido, finalización, daño, pérdida del
mueble, salidas ocupadas y colocación/uso en las cuatro alcantarillas. Se guardó
y cargó una sesión activa y se inspeccionaron capturas de ambas posturas.
Las instrucciones PRUEBAS_4_35_0e.txt incluyen la comprobación pendiente en
Windows, controles reales, guardados anteriores y recorrido del hub.

## Base aceptada: 4.35.0d1 — corrección de compilación

El autor comunica nueve errores de análisis al cargar 0d en GZDoom 4.14.2:
dos búsquedas de poses reciben String en lugar de StateLabel, restPose queda
sin declarar por ese primer error y seis llamadas no encuentran IsTimelessMap.
El catálogo entregado en 0c contiene esa función; se incluye nuevamente completo
para resolver la dependencia cuando quedó una copia anterior en el proyecto.

CaelumPlayer.UpdateCrouchVisual y CaelumRestState.Begin ahora buscan cada pose
con su etiqueta literal. Los estados, fórmulas, campos persistentes, duración,
controles y roadmap mantienen el contrato de 0d. En esa entrega se esperaban las pruebas jugables; el autor las confirma
antes de 0e.

Se reprodujeron los tres errores de poses con GZDoom 4.14.2 nativo y el catálogo
correcto. Tras aplicar la corrección, el mismo motor compiló los scripts del
proyecto reconstruido de 4621 archivos. Entorno de comprobación: Linux, SDL
sin pantalla física, renderizado por software y Freedoom 2 como IWAD de prueba.
Esto verifica análisis/compilación de ZScript, no partida en Windows, interacción,
presentación ni guardados. El motor y el IWAD no se incluyen en el parche.

PRUEBAS_4_35_0d1.txt indica cómo combinar todos los archivos, reconstruir el PK3,
comprobar el informe 0d1 y retomar Dormir/Esperar, Use y tiempo del Limbo.
El validador reconoce el sufijo numérico de hotfix sin eliminar comprobaciones.

## Base funcional aceptada con 0d1: 4.35.0d — descanso y espera

El autor aprueba todas las pruebas de 4.35.0c y autoriza continuar. Este delta
sobre 0c incorpora sesiones de Dormir y Esperar a la escala normal del mundo,
accesibles desde TAB > Mundo > D (X del mando). Se utiliza el diálogo USDF
aprobado, con selección explícita de duración: 5 minutos de juego, 1, 4 u 8
horas. La primera dura 15 segundos reales y permite una comprobación breve.
Elegir el modo no inicia la sesión; elegir la duración sí. Cerrar no concede
recuperación ni reserva una acción pendiente.

Dormir recupera Sueño de forma gradual en lugar de su consumo pasivo. Valor
provisional de prueba, no balance autoral cerrado: 100% en 8 horas de juego,
sin sobrepasar 100%. Se conservan consumo de Hambre/Sed y regeneraciones
habituales; no hay curación adicional, alimentos automáticos ni reposición
de ánima o adrenalina al comenzar/terminar. Esperar conserva la pérdida de
Sueño. La fatiga crítica no produce daño mientras se duerme, permitiendo
recuperarse desde Sueño agotado; no se anulan sus restantes penalizaciones
ni los daños por Hambre/Sed. Hambre o Sed críticas impiden continuar.

La sesión utiliza un Inventory oculto y pulsos del reloj ya existente. El
personaje queda quieto y adopta su pose mundial acostada o sentada. Puede
mirar alrededor; Q/B, movimiento o una acción lo levantan. TAB lo levanta y
abre el Diario; Escape mantiene la pausa voluntaria. La confirmación del
diálogo debe soltarse antes de armar la cancelación por entrada, y Use vuelve
a la ruta nativa al levantarse sin reescribir usedown. No se usan flags de
congelación globales ni se añade una cámara nueva o mobiliario físico.

Daño efectivo, combate, desplazamiento, agua, pérdida de suelo, otra actividad,
cambio de mapa o modificación externa del reloj interrumpen. Un sello, crafteo,
recarga/carga, conversación o viaje pendiente impide comenzar. Viajar durante
el descanso se rechaza. No se devuelven minutos ya transcurridos ni se otorga
el resto de una recuperación al cancelar. Las finalizaciones son únicas.
La sesión guardada conserva modo, duración, progreso, posición y último pulso;
al cargar continúa si el contexto sigue siendo válido. La depuración de fechas
de 0c no modifica ese reloj ni acelera el descanso.

El Limbo conserva su fecha detenida y rechaza estas sesiones por duración.
No cambian la piscina ni la regeneración previa de MAP01. El menú ofrece
preparaciones voluntarias, sin objetos: Hambre/Sed 100%, Sueño 50% o 5%.
No se aplican al abrir, cargar o viajar. ca_debug_rest_report sólo consulta;
ca_debug_rest_hit solicita un impacto nativo de 1 para comprobar la interrupción
en las alcantarillas vacías. No representa una prueba nativa ya realizada aquí.

### Verificación previa de 0d

317 aserciones sobre reglas, métodos de sesión y daño crítico extraídos del
ZScript y compilados como C++, con sanitizador de comportamiento indefinido.
33 condiciones se comprueban al iniciar y durante la sesión. Se verifican
duración, pulsos únicos del reloj, recuperación, cierre terminal, entrada y
liberación, predicción, fatiga y restauración lógica de campos. Las funciones
del motor se sustituyen por dobles de prueba: esto no verifica compilación
ZScript, física, serialización nativa ni aspecto visual de GZDoom.

Se revisan además fuentes, nuevas rutas USDF, traducciones, ancho de textos,
recursos y los cinco documentos. Al preparar 0d no estuvo disponible el motor; 0d1 incorpora la comprobación
nativa de compilación. PRUEBAS_4_35_0d.txt conserva las pruebas jugables pendientes. El ZIP
incluye sólo archivos modificados/nuevos. Se conservan mapas, audiovisuales,
atributos, tarifas, recetas y la cronología aprobada en 0c.

### Pendiente para pasar de 4.35 a 4.36

1. Completar el bloque de descanso: avance acelerado con aplicación coherente
   del tiempo e interrupciones. 0d/0d1 aportan la sesión a escala normal y 0e
   incorpora sillas/catres y cámara; 0f añade bolsa y factores de comodidad.
   0g agrega aceleración segura, mesas/comida y la regla de Lucidez del sueño.
   0h incorpora comidas automáticas de mesa, digestión y mobiliario de MAP01.
   0i corrige accesos/presentación y permite avance personal en Limbo sin calendario.
   Falta integrar los futuros sistemas temporizados del mundo.
2. Estado climático local común implementado en 0k: temperatura, viento,
   precipitación y humedad por calendario/lugar, con perfiles de ensayo.
   Pendientes aceptación de este bloque y valores regionales definitivos.
3. Planificar eventos y viajes con el mismo reloj: horarios, duración de
   rutas y resolución de acontecimientos durante espera/descanso o traslados.
4. Comprobar la integración de esos bloques con guardados, viajes y la
   excepción del Limbo, y cerrar las pruebas nativas de los incrementos.

Después continúa 4.36, entorno móvil y peligros físicos; luego 4.37, Tarot y
Trucazo. Se exporta la prueba para otros jugadores antes de V5. El trabajo
heredado/transversal, clima sobre el cuerpo, habilidades de clase/raciales salvo Sueño ya implementado,
refugios/propiedades, alimentación automática fuera de mesas y calidad amplia del descanso siguen
en V5. No se inventa un número fijo de parches para cerrar 4.35.

## Base aceptada: 4.35.0c — inicio de campaña y tiempo del Limbo

El autor aprueba todas las pruebas de 4.35.0b. Fija el inicio de los eventos
en el 3 de noviembre de 1889 a las 09:00 y establece que dentro del Limbo
no transcurre el tiempo. Este delta sobre 0b incorpora esa regla temporal
antes del siguiente incremento de descanso; V4.35 continúa con descanso,
avance temporal interrumpible, estado climático y eventos/viajes programados.

La fecha se inicializa automáticamente al confirmar el personaje. MAP01,
la mansión del Limbo, detiene el reloj global. Al salir por la ruta narrativa
a MAP02, la misma fecha comienza a avanzar. MAP02–MAP05, CADEV02 y futuros
mapas sin una excepción explícita usan un tic de reloj por tic simulado:
1 hora de juego = 180 segundos reales. No hay relojes independientes por mapa.
Una entrada de depuración al Limbo detiene la fecha alcanzada, sin reiniciarla.
No se habilita una conexión de regreso a MAP01.

La suspensión corresponde a la cronología del mundo, no a la simulación del
personaje. Se puede caminar, conversar sin pausa, usar, capturar, fabricar y
completar las pruebas del Limbo. Necesidades, regeneración, daño y recargas
conservan sus temporizadores y balance. Fuera del Limbo los diálogos siguen
consumiendo tiempo de campaña; Escape conserva la pausa voluntaria nativa.

Un guardado anterior no separaba tiempo exterior de tiempo del Limbo. Al
actualizarlo, se fija una sola vez 03/11/1889 09:00 sobre su contador actual;
se conservan CompletedDays/DayTics y todas las marcas de viajes ya registradas.
No se asigna retrospectivamente una fecha civil a esos viajes. Los calendarios
de prueba heredados de 0b se sustituyen por este inicio canónico. Los guardados
nuevos de 0c conservan su instante al cargar y al recorrer los mapas del hub.

La campaña y la vista de prueba usan anclajes separados del mismo reloj.
DateSerial/CivilDayTics consultan la campaña por defecto; sólo la UI diagnóstica
pide la prueba. Cambiar o quitar una fecha de ensayo no reinicia la campaña:
al retirar la prueba se vuelve a mostrar la fecha real que siguió avanzando.
En el Limbo se detienen ambos anclajes. Mundo indica explícitamente «El tiempo
está detenido en el Limbo». La convención estacional mensual austral de 0b
permanece como prueba: noviembre aparece como primavera; no se simula clima.

### Verificación de 0c

8.849 aserciones automáticas sobre métodos extraídos del ZScript y compilados
como C++, con sanitizador de comportamiento indefinido: 27 casos de migración,
4.320 proyecciones de campaña/prueba, fecha inicial contrastada con std::chrono,
ritmo por mapa, primera medianoche, límites y aislamiento de la depuración.
La restauración comprobada copia los campos del estado: no es serialización
nativa de GZDoom. El validador documental/de recursos y la revisión de fuentes
complementan esos cálculos. No hay motor disponible en este entorno; compilación
ZScript, migración real, guardado/carga, viaje y presentación de 0c requieren
las comprobaciones de PRUEBAS_4_35_0c.txt. El autor confirmó posteriormente
todas las pruebas de 0c; es la base aceptada de 0d.

La entrega contiene sólo fuentes/documentos nuevos o modificados y la guía
de pruebas en raíz. MAPINFO, mapas, menús de conversación, entrada de controles,
recursos audiovisuales, atributos y fórmulas del personaje se conservan.
V4 llega hasta 4.37 y luego se exporta la prueba para otros jugadores; el
trabajo heredado y transversal, incluidas las habilidades acordadas, sigue en V5.

## Base aceptada: 4.35.0b — calendario y conversaciones sin pausa

El autor aprueba todas las pruebas de 4.35.0a y autoriza continuar, incorporando
las decisiones recientes sobre conversaciones y habilidades. Esta entrega es
delta sobre 0a. Las habilidades siguen en el bloque V5 ya previsto; aquí se
registran sus efectos concretos en SYSTEMS.md, sin presentarlos como jugables.

CaelumCalendarRules convierte fechas civiles entre los años 1 y 9999, con meses
de longitud real y reglas gregorianas de bisiestos. CaelumCalendarState guarda
un anclaje respecto de CaelumWorldClock. No tiene un segundo ticker. Las
partidas nuevas y previas comienzan sin fecha de campaña, pues el autor aún
no la ha fijado. Los comandos de prueba permiten asignar una fecha explícita,
preparar una medianoche a 12 segundos simulados y retirar esa fecha sin tocar
el reloj, recursos, tareas, misiones ni marcas de viaje ya registradas.

Mundo muestra fecha y estación cuando hay anclaje. El ciclo austral mensual
de prueba usa diciembre–febrero, marzo–mayo, junio–agosto y septiembre–noviembre.
Es una convención técnica identificada como prueba, no una simulación de
equinoccios, luz, temperatura ni clima. La fecha histórica y su estación inicial
siguen pendientes de definición autoral. Los cambios del calendario de prueba
no disparan recompensas ni eventos y no equivalen a descansar o viajar en el
tiempo. El siguiente incremento de V4.35 abordará descanso y avance temporal
con sus interrupciones, seguido del estado climático y eventos programados.

MAPINFO usa UnFreezeSinglePlayerConversations en los seis mapas del proyecto.
El menú común CaelumPalomoConversationMenu omite la acción de Ticker que pausa
las conversaciones nativas a los 20 tics. Los menús derivados conservan formato, respuestas, Q/Atrás, sonidos y presentación de captura.
Esta ruta cubre también conversaciones reabiertas desde snapshots anteriores;
no escribe las flags de nivel de sólo lectura ni fuerza la pausa global.
El menú voluntario de Escape conserva su comportamiento nativo.

La propuesta adicional de cerrar automáticamente un diálogo ante cualquier
daño no se implementa en 0b. Debe comprobarse y completarse su interacción con
la cancelación nativa; el cambio autorizado aquí es mantener el mundo activo.
Socialización deberá consumir ánima durante la conversación cuando se
implemente su toggle. No se añade un coste especial por leer un diálogo.

### Verificación de 0b y límite de la entrega

La base se reconstruyó desde las fuentes del autor, con todos los deltas de
4.33.0af a 4.35.0a. El validador existente pasó antes de editar. No se dispone
del ejecutable de GZDoom en este entorno y su descarga no pudo completarse.
Por ello, no se afirma compilación ZScript, ejecución nativa, guardado/carga
ni prueba visual dentro del motor para 0b. Esas comprobaciones están descritas
en PRUEBAS_4_35_0b.txt. Posteriormente el autor confirmó todas sus pruebas;
0b queda aceptado como base de 0c.

La aritmética se extrae de las funciones ZScript y se compila como C++ para
compararla con std::chrono: 3.652.059 fechas civiles, 7.840 combinaciones de
entrada válidas/inválidas y 1.728 proyecciones del anclaje. También se revisan
las estaciones mensuales y los límites enteros. Esta prueba comprueba los
cálculos; no sustituye al compilador ni a la máquina virtual de GZDoom.
El validador documental/de recursos termina sin errores. La revisión confirma
cinco clases USDF bajo el menú común, ocho claves nuevas en ambos idiomas y
494 MU como ancho conservador máximo de la fecha dentro de 544 MU disponibles.
MAP01–MAP05, CADEV02, fuentes, sonidos, sprites y modelos conservan sus bytes.

## Base aceptada: 4.35.0a — reloj global persistente

El autor confirma «Todo correcto ahora sí» para 4.34.0e. Quedan aceptadas
las pruebas de sello, crafteo, recuperación de Use y viaje. Se continúa con
el reloj global, primer incremento de 4.35; el calendario, descanso, clima
y eventos mantienen su lugar dentro del bloque.

CaelumWorldClock registra jornadas completas y tics del día en un Inventory
nativo del personaje. CaelumWorldClockTicker es un observador estático sin
estado temporal propio: consulta ese Inventory y avanza una vez por tic de
simulación, después de confirmar el perfil. También se registra al cargar
un guardado que no incluía este sistema. La base actual es individual.

Se conserva la escala aprobada: 1 hora de juego = 180 segundos reales de
simulación, 24 horas por día. A 35 tics/s, la hora tiene 6300 tics y el día
151200. Los contadores enteros evitan acumular redondeos. TAB > Mundo muestra
«Tiempo registrado», expresado en días transcurridos y HH:MM, junto a la escala.
No equivale a una fecha narrativa ni atribuye estaciones o cambios de luz.

El motor determina qué tiempo se simula. Pausa, menú nativo y conversaciones
que pausan el juego detienen el reloj. El Diario no pausa la simulación;
trabajar en una estación sigue consumiendo tiempo normal. Guardar/cargar
conserva el contador; viajar y volver a un mapa del hub conserva el reloj
viajero, sin restaurar la hora del snapshot antiguo del lugar. No se suma
el tiempo que GZDoom estuvo cerrado ni el de una carga. Volver a una partida
guardada restaura su instante guardado. Una partida nueva tiene otro registro.

Un guardado anterior empieza a registrar desde cero al instalar 0a; no se
infiere duración pasada a partir del mapa o las misiones. Las salidas/llegadas
nuevas de alcantarilla guardan marcas del mismo reloj. No se fechan viajes
históricos de 0e ni se añade duración a rutas todavía sin tiempo definido.
El informe netevent ca_debug_time_report sólo consulta. El informe de viajes
muestra las marcas cuando existen. No se alteran los costes o temporizadores
aceptados de necesidades, combate, sellos y fabricación.

Entrega delta sobre 4.34.0e, con README inglés, cinco documentos canónicos y
PRUEBAS_4_35_0a.txt en la raíz. V4 continúa hasta 4.37; después se prepara la
exportación para otros jugadores. Todo el trabajo heredado y transversal
sigue en V5, comenzando por la reorganización del código en V5.0.

### Verificación nativa de 0a

GZDoom 4.14.2/Linux, con Freedoom 0.13.0 y llvmpipe: 35 observaciones
correctas, sin errores de script ni abortos de ejecución en los seis casos
finales. Nueve comprueban creación, escala, Inventory oculto único, límites
enteros de hora/día, saturación, consulta sin cambios y avance exacto por tic.
Los límites extremos se preparan en un contador aislado; no representan
jornadas completas transcurridas durante una prueba manual.

Siete observaciones usan teclado real: pausa nativa, menú Esc, conversación
USDF, sus respectivas reanudaciones y Diario abierto con simulación activa.
Mundo se inspecciona en una captura nativa en español con cinco visitas y tres
salidas preparadas para verificar el espacio disponible. La nueva línea cabe
sin superponerse a los registros ni a los controles existentes.

Siete observaciones recorren MAP02 → MAP03 en caravana y el regreso por una
reja con Use real. El reloj acompaña al personaje, conserva el inventario y
fecha ambas rutas; volver al hub no recupera la hora antigua de MAP02.
Reconciliar de nuevo una llegada resuelta conserva sus marcas y contadores.
Tres observaciones cargan el guardado nativo de ese recorrido y verifican el
instante guardado, la llegada única y la continuación exacta por tic.

Se crea además un guardado ejecutando las fuentes originales de 4.34.0e,
después de una llegada real a MAP03. Se superponen las fuentes 0a en la misma
ruta antes de cargarlo. Seis observaciones comprueban el reloj nuevo desde
cero, el historial anterior sin fechas inventadas, la llave y reservas
conservadas, la caravana disponible y las marcas del primer viaje posterior
a la actualización, incluido el regreso al snapshot anterior de MAP02.

Las tres observaciones restantes cruzan un fin de día preparado usando tics
reales y comienzan otra partida mediante el motor: el nuevo personaje tiene
un solo reloj y empieza desde cero. No se repite toda la historia de MAP01
ni toda la fabricación ya aceptada. Fixtures, motor, IWAD y guardados quedan
fuera de la entrega. El validador del proyecto comprueba los cinco documentos
actualizados y termina sin errores. El autor confirmó después todas las pruebas de 0a en Windows.


## Base aceptada: 4.34.0e — medios para comprobar actividades y viaje

El autor aprueba lo que pudo probar de 0d, pero no pudo comprobar sellos o
crafteos porque las alcantarillas estaban vacías. Esas dos pruebas no se dan
por aprobadas. 0e completa sus medios antes de avanzar al reloj de 4.35.

En cada alcantarilla MAP02–MAP05 hay un banco, un aserradero y una forja
nativos cerca de la llegada. La oferta existente TAB > Mundo > C/Y agrega
«Preparar sello» y «Preparar crafteo». Son ayudas de diagnóstico voluntarias:
no inician un traslado, una canalización ni una tarea por sí mismas.
La primera reutiliza o concede quintaesencia T1, la equipa mediante la ruta
normal y recarga adrenalina al máximo vigente; su texto avisa que también
quita la espera del sello. No provoca un combate ficticio. La segunda enseña
Mango y completa hasta 40 unidades de madera para el lote x10. Las entregas
respetan capacidad de carga. Repetir no duplica el sello poseído ni añade
madera sobre ese lote. Cargar o viajar no reponen recursos.

Usar una estación de esta red, después de preparar la receta, preselecciona
Mango T1, lote x10 y eficiencia 100%. Son valores existentes; el tiempo de
trabajo se calcula con la Destreza real. Enter inicia la fabricación normal,
Q deja la tarea pendiente y TAB > Mundo > C debe rechazar el viaje. Volver
con Usar permite cancelar con C o terminar. Para el sello se usa su control
habitual con un arma equipada, y se prueba tanto cancelación como agotamiento.

Las estaciones se reconstruyen una vez en guardados anteriores y mantienen
su grupo y estado dentro del hub. Los mapas, puntos de llegada y seis rutas
son los existentes. No hay regreso a MAP01 ni cambios de misión, atributos,
receta, coste, consumo o efecto de quintaesencia. La entrega es delta sobre
0d con PRUEBAS_4_34_0e.txt fuera de docs. Después de aceptar estas pruebas
sigue V4 hasta 4.37, exportación para otros jugadores y trabajo heredado y
transversal en V5 (primero refactor V5.0).


La prueba real de iniciar/cerrar/reanudar reveló que el Diario consumía
KeyUp de +use al abrir Oficios. 0e deja llegar esa liberación al motor para
que el siguiente Use funcione después de Q; no cambia las pulsaciones de
navegación aprobadas. La secuencia se comprueba sin liberar el botón mediante
comandos de depuración ni asignar CraftingTaskActive/CombatChannelModeActive.

### Verificación nativa de 0e

GZDoom 4.14.2/Linux, con Freedoom 0.13.0 y llvmpipe: 50 observaciones del
recorrido jugable verifican la oferta por Mundo/C, equipamiento nativo,
User2 real, bloqueo con canal activo, cancelación, agotamiento natural,
recuperación de Use, receta y lote disponibles, Enter, Q, bloqueo por tarea
pendiente, reanudación, cancelación y producción con el avance T existente.
Se recorren los seis sentidos en caravana; los cuatro mapas permiten usar
sus estaciones, y el hub conserva grupos, materiales, producto e ItemId del
sello. Las ayudas no crean un viaje ni se repiten por cargar o cambiar de mapa.
El perfil de diagnóstico iniciado por consola se equipa con una daga nativa
para representar el arma que el jugador trae de MAP01. No se asignan los
booleanos de canal ni fabricación para simular que se inició una actividad.

Siete observaciones adicionales cargan un guardado nativo con la fabricación
real pendiente: conserva reservas y pausa, sigue rechazando el viaje, reanuda
con Use y permite cancelar sin consumir ni duplicar. Después se confirma una
caravana real y se registra una sola llegada. Los fixtures y guardados son
privados de verificación y no forman parte del ZIP de fuentes.

La compatibilidad se comprueba con un guardado creado ejecutando las fuentes
originales de 0d, dentro de una confirmación de caravana. Se superponen las
fuentes 0e en esa misma ruta antes de cargarlo. Cuatro observaciones verifican
la página restaurada sin salida automática, tres estaciones tras cerrar el
diálogo, inventario/necesidades conservados y preparación nueva disponible
sin fabricar historial de viajes. No se sustituye esa comprobación por una
partida nueva. La validación del autor en Windows sigue pendiente.

Tres comprobaciones adicionales rechazan acciones de suministros fuera de
su conversación e identificadores inválidos, sin conceder objetos ni crear
viajes. Total: 64 observaciones nativas correctas en esta verificación.
La oferta española y el puesto físico de MAP02 se inspeccionan en capturas
nativas: las seis respuestas y las tres estaciones son visibles. El validador
del proyecto termina sin errores; los cinco documentos tienen versión 0e.
Se conservan por comparación de bytes mapas, assets, reglas, atributos y el
jugador. Sólo el Diario cambia la liberación de Use, y la presentación de
estaciones se limita explícitamente a las alcantarillas de prueba.

## Incremento anterior: 4.34.0d — caravanas y registro de viajes

El autor confirma «Todas las pruebas dieron correcto» para 4.34.0c y autoriza
el siguiente parche. Se acepta la red MAP02–MAP05, sus seis sentidos y el hub,
con la prohibición de volver a MAP01. Continúa el orden V4 hasta 4.37,
exportación de prueba para otros jugadores y después todo lo heredado y
transversal en V5, empezando por el refactor V5.0.

0d incorpora la base de servicio de caravanas mediante una prueba explícita
en TAB > Mundo > C (Y del mando). Ofrece únicamente las conexiones de la
alcantarilla actual. El diálogo nativo separa selección, vuelta a destinos,
cancelación y confirmación. No es un NPC de campaña ni asigna una facción;
la prueba no cobra, no crea vehículos ni simula una duración.

Los accesos físicos y la caravana comparten CaelumTravelService. Antes de
salir se comprueban perfil, vida, origen, destino disponible, actividad,
predicción, partida individual y ausencia de otro traslado pendiente. Los
accesos conservan además sus comprobaciones de colocación, alcance y visión.
El motor mueve el inventario real y conserva el hub. El regreso narrativo
MAP01 → MAP02 sigue con su confirmación y saneamiento exclusivos.

CaelumJourneyState, un Inventory nuevo y oculto, registra último trayecto,
modo, secuencia y cantidades de llegadas/interrupciones. Una llegada sólo se
cuenta en el destino esperado y con su conexión pendiente. Repetir la consulta
o cargar una llegada resuelta no duplica contadores. Otra llegada, una marca
incompatible o cargar una salida aún en origen la interrumpe sin reintento.
La consulta de un guardado 0c no inventa historial; éste comienza al viajar.
Mundo muestra el último viaje y ofrece la prueba. El informe de consola
netevent ca_debug_travel_report es de sólo lectura.

La base de servicios y registro de 4.34 queda implementada; los horarios,
duraciones e integración temporal de eventos continúan en 4.35 con el reloj.
Los transportes, minimapa de viaje, incidentes y desvíos del diseño amplio
siguen planificados y no se presentan como contenido jugable de este ensayo.
El siguiente incremento previsto es el reloj global de 4.35, sujeto a la
validación del autor de 0d. El refactor del código permanece en V5.0.

Entrega delta sobre 0c con README inglés, cinco documentos canónicos y
PRUEBAS_4_34_0d.txt fuera de docs. No incluye motor, IWAD, guardados ni fixtures.


### Verificación de 0d y límites

En GZDoom 4.14.2 nativo, con Freedoom 0.13.0 y llvmpipe/Linux, se completan
57 observaciones de comportamiento: 27 de guardas y conciliación, 21 de
selección/cancelación/seis sentidos y Use real, dos de conversación guardada,
cinco de migración desde fuentes originales 0c y dos de recarga en destino.
Los casos de conciliación preparan marcas de salida para probar rechazo,
interrupción y resolución sin atribuirles recorridos reales.

La prueba de teclado entra desde Mundo con C, usa respuestas explícitas de
USDF y conserva carta sellada, llave de plata, reputación y necesidades durante
los traslados. La conversación guardada estaba en la confirmación de MAP04;
al cargar continúa allí sin salir sola y una confirmación produce una llegada.
El guardado 0c se creó ejecutando sus fuentes originales y se cargó tras
superponer 0d en la misma ruta de prueba. La Caja conserva ItemId 1, junto a
llave, carta sellada, reputación 47 y necesidades, antes y después del viaje.
El guardado posterior contiene los snapshots MAP02/MAP03 y el registro de
llegada; cargar no vuelve a contarlo. No se simula una nueva partida como si
fuera un guardado anterior. No se repite toda la historia ni toda la fabricación.

Mundo se inspecciona en español e inglés con cinco visitas y tres salidas
preparadas para verificar su disposición completa; la página de confirmación
se captura durante la conversación nativa. Se conservan los mapas, assets,
atributos, inventario narrativo y entradas aceptadas; la nueva tecla sólo
actúa en Mundo de las alcantarillas. Validación del autor en Windows pendiente.

## Base aceptada: 4.34.0c — red de alcantarillas de prueba

El autor confirma «Todo correcto» para 4.34.0b. Autoriza conectar MAP02 con
otros mapas de alcantarilla, destinados a pruebas masivas, de Tarot y de los
sistemas siguientes. Deja a criterio de implementación las conexiones, salvo
volver a MAP01. Esta autorización amplía el espacio de pruebas de V4; la
campaña completa y el trabajo heredado/transversal conservan su lugar en V5.

Se incorpora una red en estrella: MAP02 conecta con MAP03, MAP04 y MAP05;
cada ramal vuelve a MAP02. No hay acceso normal de vuelta a MAP01. Las seis
direcciones tienen registros independientes. El regreso narrativo conserva
su identidad 1, confirmación, limpieza del Limbo y llegada con la Voz.

| Mapa | Espacio y finalidad | Acceso desde MAP02 |
| --- | --- | --- |
| MAP02 | Llegada existente y distribución de pruebas | Se conserva la llegada del prólogo. |
| MAP03 | Depósito de 4096 × 3072 MU, centro amplio, canales laterales y pilares periféricos; base para pruebas masivas futuras | Portón izquierdo al fondo norte, en (-236, 1104, 0). |
| MAP04 | Cámara central con cámaras laterales y posterior; base para Tarot futuro | Portón derecho al fondo norte, en (236, 1104, 0). |
| MAP05 | Mantenimiento: planta baja, dos escaleras de ocho peldaños de 12 MU y galería superior a +96 MU | Portón de la pared derecha/este, en (344, 448, 0). |

Acercarse al portón muestra su destino y la indicación de Usar. El viaje
se solicita con la tecla Usar habitual. Al entrar en MAP03–05 se mira hacia
el interior; el portón de vuelta queda detrás. Al volver a MAP02 se utiliza
el PlayerStart existente (-236, 32, 0), separado de los portones. Mantener
Usar durante la carga no produce un viaje de rebote. No hay costes, tiempo
ficticio de viaje, carga automática de enemigos ni cartas de regalo.

Los cuatro mapas de alcantarilla pertenecen al hub nativo 434. GZDoom guarda
sus actores, objetos dejados y geometría modificada para el regreso y para
guardados de la sesión. El inventario del personaje viaja como sus propias
instancias. Cambiar entre alcantarillas no vuelve a ejecutar la limpieza del
Limbo, no cura ni repone necesidades. Se rechaza viajar con actividades o
menús activos, congelación ajena, personaje inválido, origen equivocado,
destino ausente o varios jugadores; no se fuerza la salida del resto.

Se conservan los bytes de MAP01, MAP02 y CADEV02. Los portones se reconstruyen
desde el controlador existente, por lo que también aparecen al cargar MAP02
de 0b. Preparar otra vez no duplica accesos. No se cambia el esquema del
Inventory persistente: capacidades 32 y versión de Mundo 1; se añaden sólo
identidades de contenido en las posiciones reservadas del catálogo.

TAB > Mundo presenta visitas en una columna y salidas conocidas del mapa
actual en otra. Acercarse a un acceso lo descubre; la visita y el recorrido
se acreditan al llegar. Conocer o recorrer la ida no inventa la vuelta.
El Diario sigue siendo de consulta. Las flechas y RePág/AvPág conservan sus
acciones aceptadas. El regreso al cuerpo completado se informa al pie como
un trayecto sin paso de vuelta a la mansión.

### Verificación y límites de 0c

- 23 comprobaciones de catálogo, reconstrucción, origen/distancia/altura,
  predicción, muerte, creador, actividades, menús, congelación, descubrimiento
  y consulta sin alterar misiones, Tarot ni atributos.
- 42 comprobaciones durante los seis trayectos nativos y una revisita:
  tecla Usar real, direcciones independientes, llaves/cantidades/reputación,
  necesidades sin rellenar, ausencia de población masiva automática, actores
  y objetos del suelo conservados y subida caminando por la escalera real.
- Ocho comprobaciones nuevas al cargar el guardado de la red: mapa actual,
  visitas/direcciones, inventario, recursos y snapshot inactivo de MAP02,
  seguido por el viaje nativo de regreso sin duplicar portones.
- Diez comprobaciones al actualizar un guardado creado con las fuentes
  originales 0b: adopción del hub, reconstrucción de tres accesos, identidades
  de Caja/arma, ubicación en mochila y durabilidad originales, carta/encargo/
  recompensa única/reputación, viaje a MAP03 y vuelta conservando un actor
  que ya estaba en el guardado 0b. El fixture prepara esos datos en 0b;
  no sustituye a una repetición completa del prólogo.
- Se verifica además la salida narrativa real desde sus requisitos preparados:
  Usar/confirmación nativa, marca pendiente, limpieza original, Caja/primera
  arma en Caja, carta, llegada a MAP02 y coexistencia de la Voz con los accesos.
- Revisión visual nativa de portón, depósito, cámaras, escaleras y Diario
  completo en español/inglés. Para la captura de maquetación del Diario se
  preparan las cinco visitas y seis recorridos en un fixture privado.

Entorno: GZDoom 4.14.2, Freedoom y llvmpipe/SDL en Linux. Los fixtures de
prueba preparan posiciones, algunos objetos y estados; no se distribuyen.
La comprobación de 0c por el autor en Windows queda pendiente. La capacidad
de MAP03 para una población concreta aún debe medirse: no se declara una
prueba masiva aprobada. MAP04 no adelanta activaciones nuevas de Tarot y
MAP05 no aplica todavía peligros, daño ambiental ni inmersión profunda.

Entrega: delta sobre 4.34.0b, generador UDMF reproducible en assets/generators,
README inglés, cinco documentos canónicos y PRUEBAS_4_34_0c.txt fuera de docs.
La arquitectura modular aquí es de mapas. El refactor transversal del código
sigue en V5.0. En 4.34 quedan las bases de caravanas e integración de viajes;
sus duraciones/eventos se apoyarán en el reloj de 4.35. Después continúan
4.36, 4.37 y la exportación de prueba para otros jugadores antes de V5.

## Base aceptada: 4.34.0b — puertas y accesos por grupo

El autor confirma «Todo correcto» para 4.34.0a y autoriza el siguiente parche.
Quedan aceptados Mundo, lugares visitados, regreso registrado y compatibilidad
de partidas. Se mantiene la decisión: terminar V4 hasta 4.37, exportar una
prueba para otros jugadores y después abordar en V5 todo lo heredado y transversal.

0b continúa las bases de arquitectura con puertas cerradas y requisitos de
acceso. La revisión encuentra tres rutas de apertura no deseadas: una hoja
libre podía eludir la llave o el bloqueo de arena de otra; además, todas las
puertas con id cero se trataban como un grupo. Se comprueba el comportamiento
con las fuentes 0a antes de corregirlo. Ahora se validan llave, arena y condición
de reputación de cada hoja antes de alterar peticiones o temporizadores.
Sólo los ids positivos enlazan hojas; sin id cada puerta funciona sola.

El cierre comprueba el hueco original y el radio/altura del personaje, incluso
cuando las hojas se apartaron. Mantiene abierto el grupo completo mientras el
jugador ocupa el paso y lo reabre si entra durante el cierre. La pérdida de la
llave no lo encierra en una puerta ya abierta; una vez cerrada, la próxima
petición requiere la llave de nuevo. El bloqueo expreso de la arena conserva
su prioridad previa. Las velocidades, recorrido y espera normal se conservan.

LOCKDEFS sigue siendo la autoridad de llaves y no las consume. Su consulta
silenciosa precede al mensaje/sonido limitado por el temporizador existente.
Las cerraduras 200/201 y la nueva 202 usan el sonido propio de puerta bloqueada,
sin superponer una reproducción manual al sonido nativo.

### Prueba opcional accesible

En una zona despejada de MAP01 o MAP02, cerrar diálogo/comercio y usar:
`give CaelumDebugDoorTrial`. Coloca una puerta de dos hojas delante del personaje;
sólo una declara la cerradura 202. Usar cualquiera sin la llave debe rechazar
ambas. `give CaelumDebugDoorKey` entrega una única llave nativa reutilizable,
independiente de la llave de plata. Usar abre el grupo; permanecer en medio
mantiene el paso abierto y retirarse permite el cierre normal.

`give CaelumDebugDoorTrialOff` retira esas hojas y su llave. Los bloqueadores
se eliminan en sus siguientes ticks. Repetir la activación conserva las mismas
instancias. La prueba no entrega la llave de Argento, modifica reputación,
activa misiones ni registra nuevos viajes. No añade un obstáculo de campaña:
su presentación aislada sólo aparece al solicitarla. La llave es un marcador
Key sin peso ni fila de equipo. Puede guardarse y cargarse con la prueba.

`netevent ca_debug_door_report` consulta habilitación, llaves separadas, mapa,
grupo, cerradura y progreso/espera/ocupación de cada hoja. No abre puertas ni
crea la prueba. Los diagnósticos de Mundo, integración y El Loco siguen
funcionando y actualizan su cabecera a 4.34.0b.

### Evidencia y límites

- Veinte comprobaciones nativas de requisitos, rechazo sin cambios parciales,
  id cero/negativo, grupos diferentes, llave reutilizable, condiciones sociales,
  arena, predicción, desnivel, ocupación en ambos ejes y peticiones de NPC.
- Diecisiete comprobaciones de uso nativo: comandos de prueba, conservación de
  instancias, tecla Usar en ambas hojas, llave incorrecta/correcta, colisión al
  entrar, permanencia más allá de la espera normal, pérdida de llave, cierre y
  reapertura al entrar durante su movimiento. Repetirlas en inglés verifica
  los textos y no aumenta la cantidad de casos distintos.
- Ocho comprobaciones nuevas al recargar una puerta 0b parcialmente cerrada:
  referencias, configuración, posición/progreso, llaves, consulta sin efectos,
  continuación, retirada de la prueba y ausencia de bloqueadores huérfanos.
- Siete comprobaciones nuevas al cargar un guardado producido con las fuentes
  originales 0a y una puerta parcialmente abierta: actores/configuración,
  movimiento, Mundo, llave/reputación, apertura/cierre y protección de la hoja
  restaurada. La comprobación de preparación serializada no se cuenta otra vez.
- Colocación de la prueba desde el inicio existente de MAP02 y conservación de
  sus visitas/Tarot sin inventar un regreso. Capturas nativas revisadas en
  MAP01/MAP02; mensajes en español e inglés.

Entorno: GZDoom 4.14.2, Freedoom, llvmpipe y teclado SDL en Linux. La prueba
prepara posiciones y una llave de plata adicional sólo en los fixtures privados
para comprobar que no sustituye a la llave 202 y que la retirada no la borra.
No repite toda la campaña ni acredita cooperativo. La ocupación automática
protege jugadores; el cierre forzado de la arena mantiene su contrato previo.
El autor confirma después «Todo correcto» para 0b y autoriza 0c.

Delta sobre 4.34.0a con README, cinco documentos canónicos y PRUEBAS_4_34_0b.txt.
Los 52 actores de puerta originales de MAP01 ya usan grupos positivos; sus
números, posiciones y mapas no cambian. No se modifican atributos, navegación,
misiones, inventario narrativo ni el esquema persistente de Mundo. El siguiente
incremento continúa arquitectura, módulos y accesos entre plantas de 4.34;
calendario, peligros, Tarot/Trucazo y exportación conservan su orden.

## Base aceptada: 4.34.0a — ubicaciones y conexiones

El autor dispone completar el roadmap actual de V4, preparar después una
exportación de prueba para otros jugadores y trasladar todo el trabajo
heredado y transversal a V5 tras esa exportación. Autoriza continuar con el
próximo parche; esta decisión permite avanzar desde el cierre técnico 0ao.
No se registra una confirmación adicional de todas las pruebas de 0ao.

4.34.0a inicia el catálogo del mundo y sustituye la pantalla provisional de
TAB > Mundo por ubicación actual, lugares visitados y conexiones conocidas.
Usa los nombres ya existentes de MAP01 y MAP02. La conexión «Regreso al cuerpo»
se conoce cuando la salida narrativa está preparada; su destino permanece
«Por descubrir» hasta llegar. En MAP02 queda «Recorrida» y se indica que es
un viaje de ida. El Diario informa; la confirmación sigue en el umbral.

El registro reside en el Inventory persistente del personaje, con ids estables,
visitas, conocimiento, recorrido y una conexión pendiente. Después del Commit
validado se registra la salida pendiente; sólo la llegada correspondiente la
convierte en recorrida. Guardar, mirar el Diario o consultar la consola no
viaja ni concede recompensas. Se conservan la limpieza del Limbo, la Caja, la
primera arma, El Loco y los contratos de misiones/reputación de 4.33.

Los guardados anteriores registran el lugar actual. Un guardado de MAP02 con
MAIN_M00 completa, primera arma preservada y limpieza final documentadas
recupera también la visita a la mansión y el regreso realizado. Entrar en MAP02
mediante «map map02» sin esos hechos registra sólo las alcantarillas. CADEV02
y mapas sin ficha no adquieren un id de campaña. No se infiere una ruta inversa.

Consulta explícita: `netevent ca_debug_world_report`. Lee versión del registro,
mapa/id actual, visitas, conexión conocida/recorrida y pendiente, sin crear
registros ni tocar misiones, inventario o atributos. Los diagnósticos anteriores
siguen disponibles y actualizan su cabecera a 4.34.0a.

### Verificación de 4.34.0a

- Dieciocho comprobaciones de arranque, ids y guardas, consulta y navegación
  nativa del Diario: personaje válido, creador/muerte/predicción, rechazo de
  salida no confirmada, id pendiente inválido e izquierda/derecha/RePág/AvPág.
- Cuatro comprobaciones específicas del recorrido: guardado anterior de MAP01,
  fundido confirmado todavía sin destino visitado, salida pendiente antes de
  ChangeLevel y llegada real con las dos visitas y la conexión recorrida.
  El escenario reutiliza además captura, cancelación, +2%, limpieza, comercio,
  misiones, recompensas y llegada nativa verificados en 0ao.
- Seis comprobaciones al cargar un guardado nativo 0ao de MAP02: migración de
  mundo, Caja/primera arma/Tarot, finales y constancias únicas, reputación y
  comercio conservados, sin repetir el diálogo de llegada ya terminado.
- Cuatro comprobaciones de una sesión nueva iniciada directamente en MAP02:
  ubicación actual sin inventar la mansión ni su regreso; un intento pendiente
  sin evidencia de salida tampoco obtiene recorrido.
- Se guarda y recarga el registro nuevo en MAP01 y MAP02. Los campos nativos
  persisten; el autoguardado de llegada también contiene visitas y recorrido.
  Las verificaciones serializadas de preparación no se cuentan como nuevas.
- Render nativo de Mundo antes del regreso y tras llegar; textos de la conexión
  conocida revisados en español e inglés. La escena visual prepara sólo el
  conocimiento de la conexión para comprobar que oculta el nombre del destino.

Entorno técnico: GZDoom 4.14.2, Freedoom, teclado SDL y llvmpipe en Linux. Los
escenarios de integración parten de guardados de QA y preparan el registro de
primera arma; no repiten todas las pruebas de residentes ni toda la fabricación.
El autor confirma posteriormente «Todo correcto» y autoriza 4.34.0b.
Motor, IWAD, guardados, fixtures y capturas privadas no forman parte del delta.

Entrega sobre 4.33.0ao: README, cinco documentos canónicos y
PRUEBAS_4_34_0a.txt. Los mapas, assets, fórmulas de atributos y controles de
Inventario/Misiones permanecen iguales. No hay nuevos destinos, viaje rápido,
precios/duraciones de viaje, calendario ni contenido de campaña en este parche.
Los siguientes incrementos de 4.34 continuarán sus bases de arquitectura,
conexiones y viajes; 4.35–4.37 y la exportación siguen en el roadmap inferior.

## Base técnica: 4.33.0ao — cierre de integración

El autor confirma que todas las pruebas de 0an dieron correcto y autoriza el
siguiente parche, solicitando primero el roadmap completo de V4. Quedan
aceptados requisitos de reputación/pertenencia, diálogo, acceso, comercio,
guardado y controles de la prueba. 0ao verifica su convivencia con misiones,
captura y salida narrativa, conservando las reglas aprobadas.

Se añade `netevent ca_debug_integration_report`: consulta de los registros
existentes del jugador que la solicita. Muestra MAIN_M00, objetivos y finales
de los dos encargos, entrega registrada y constancia presente por separado,
las cuatro reputaciones/pertenencias, Caja, primera arma, Tarot, condiciones
comerciales, pruebas habilitadas y estado de salida/llegada. No crea ni repara
registros, concede recompensas, cambia reputación ni activa demostraciones.
El informe detallado de El Loco sigue disponible, con cabecera 4.33.0ao.

### Conversación activa al cargar

La recarga del autoguardado de llegada reproduce una diferencia concreta:
ConversationNPC y bInConversation siguen activos, pero no existe menú USDF.
La Voz queda marcada como iniciada y la prueba de reputación espera ese diálogo
invisible. Con la función nativa StartConversation se vuelve a mostrar el diálogo
del mismo interlocutor sin elegir respuestas ni ejecutar recompensas.

CaelumConversationResume es un StaticEventHandler registrado en MAPINFO.
Recibe WorldLoaded con IsSaveGame y difiere la reapertura al primer WorldTick.
Comprueba personaje vivo/creado, interlocutor activo con conversación y
ConversationPC igual al jugador. Usa la orientación guardada y saveAngle=false;
no llama a Used, reasigna un árbol, borra referencias ni modifica registros.
No se ejecuta en una entrada normal de mapa ni sobre referencias inactivas.
Su marcador es estático y no añade datos al guardado. Se corrige también la
recarga del autoguardado creado antes de este arreglo.

### Comprobación conjunta y límites

Se crea un guardado nativo con las fuentes originales 0an: Caja recibida en
el diálogo de Palomo, una compra real de cinco maderas por 14 cobres, comercio
con condición/rebaja activos, reputaciones y pertenencias distintas, Recorrido
terminado con constancia y Espera activa con tiempo transcurrido. Al cargarlo
con 0ao se comprueba conservación y ausencia de repetición de la transacción.
Se cierra el comercio con Q y se recorre con teclado nativo la revelación,
cancelación y captura explícita de El Loco, su animación y bonificación única.

La salida se confirma por la puerta y el diálogo existentes. El fundido y
la limpieza del Limbo preceden al viaje: se conservan Caja, primera arma en
ella, carta, registros sociales y constancias; se retiran los objetos físicos
de prueba sujetos a esa limpieza, incluidos monedas y madera comprada. El
comercio se cierra y su rebaja temporal no se convierte en una rebaja negociada.
La prueba de reputación no puede interrumpir la Voz de llegada; después se
reabre en MAP02. Espera conserva su estado hasta completar/cobrar, y los
finales/recompensas permanecen únicos. Retirar la prueba conserva los registros.

Se recarga también el guardado final de MAP02: ambos encargos y constancias,
reputaciones, Caja/arma/carta, existencias comerciales y retirada de la prueba
se conservan. No vuelve a abrirse el diálogo ya cerrado. La consulta de
integración deja intactos inventario, salud, reloj y registros examinados.

Pasan 39 comprobaciones de integración: 17 nuevas al continuar el guardado
0an en MAP01, 16 de llegada/encargos y seis de recarga final. Los cuatro
controles de preparación guardados con 0an no se suman otra vez. Las seis
comprobaciones repetidas al reabrir diferentes páginas tampoco se duplican;
se verifica por el menú nativo la recuperación de ambas páginas guardadas.

Las escenas privadas parten después de las pruebas de residentes y preparan
el objetivo de Recorrido y el registro de primera arma para ensayar contratos.
No repiten toda la campaña ni su fabricación. El motor, IWAD, entradas SDL y
guardados de QA quedan fuera del parche. Entorno: GZDoom 4.14.2, Freedoom y
llvmpipe en Linux; la comprobación del autor en Windows de 0ao queda pendiente.
La evidencia de bloques anteriores ya aprobados se conserva y no se vuelve a
contar como pruebas nuevas. El autor autoriza después continuar con 4.34.0a.

Entrega delta sobre 0an con README, cinco documentos canónicos y
PRUEBAS_4_33_0ao.txt. Mapas, assets, fórmulas de atributos, estados serializados,
condiciones de reputación y lógica de misiones se conservan. El autor autoriza continuar con 4.34.0a: ubicaciones y conexiones.

## Base aceptada: 4.33.0an — condiciones de reputación

El autor confirma que 0am funciona y valida los dos encargos opcionales:
completarlos entrega las constancias, abandonar Recorrido impide aceptar
Espera y viajar a MAP02 antes de completar el objetivo de Recorrido lo falla.
Quedan aceptadas las correcciones de captura, sellos y navegación. Mantener
los atributos vigentes y los controles de extremos del Diario.

0an conecta el registro existente con condiciones reutilizables para abrir
diálogos, puertas deslizantes y comercio. Cada condición declara facción,
mínimo inclusivo y pertenencia opcional. La pertenencia no sustituye el mínimo.
Las puertas validan el grupo completo antes de moverlo; las transacciones
revalidan antes de intercambiar monedas u objetos. La rebaja por reputación
es temporal y separada de la rebaja negociada persistente.

### Prueba accesible y alcance

Guardar antes y ejecutar `give CaelumDebugReputationTrial`. La prueba se abre
inmediatamente; luego TAB > Reputación > F/Y la reabre. Ofrece cinco estados
seleccionables y tres servicios reales. Usa Gendarmería como id técnico:

| Servicio de prueba | Requisito |
| --- | --- |
| Información | Reputación >= 25 |
| Puerta física | Miembro y reputación >= 25 |
| Comercio | Reputación >= 0 y Caja propia |
| Rebaja comercial | Reputación >= 25; márgenes existentes 140%/60% |

Los cinco estados son 0 sin pertenencia, 25 sin pertenencia, 25 miembro,
-25 miembro y 0 miembro. Modifican el registro real de Gendarmería; conservan
las otras facciones. La prueba usa inventario, monedas y existencias reales,
sin entregar Caja, recursos ni recompensas. Cerrar comercio con Q/B; Esc
conserva el menú de pausa del motor. Para quitar la prueba, cerrar sus menús
y usar `give CaelumDebugReputationTrialOff`: retira guía y puerta, sin revertir
la reputación. Cargar el guardado anterior restaura el estado previo a probar.

No se asigna facción a los residentes del Limbo ni se alteran sus pruebas
sociales. Los cuatro ids actuales, escala -1000..1000 y relaciones existentes
se conservan. Las ocho facciones narrativas, siete rangos y relaciones futuras
siguen pendientes de umbrales y matriz del autor. Los valores de esta prueba
no fijan ese diseño. No se añaden mapas, misiones, ganancias de reputación de
campaña, fórmulas de precio regional ni bonificaciones de atributos.

### Evidencia y validación de 0an

Treinta y siete comprobaciones nativas cubren límites e ids inválidos,
pertenencia independiente, facción correcta, rechazo de acciones fuera del
diálogo, condiciones de grupos de puertas, compras/ventas reales, cotización
cambiada y cierre por pérdida de acceso. Se verifica la separación entre
rebaja temporal y negociada, conservación de monedas/stock al rechazar y
ausencia de duplicación o alteración de misiones, Tarot y atributos.

Diecinueve comprobaciones de interfaz usan eventos SDL de teclado: activación,
reapertura con F, estados del menú nativo, permiso de diálogo y puerta, precios
y compras con Enter, cierre con Q, controles de Reputación y retiro de la prueba.
Se revisan los textos españoles e ingleses con el render nativo; repetir
los mismos casos por idioma no añade casos distintos.

Un guardado nativo creado por las fuentes originales 0am conserva al cargar
con 0an las cuatro reputaciones/pertenencias, Caja, monedas, atributo, agua,
misión terminada, constancia y oferta sucesora. Un comercio ya abierto conserva
su rebaja negociada sin recibir requisitos nuevos ni activar la prueba.
Después se guarda y carga una sesión con condiciones 0an: se conservan sus
campos, descuento y referencias de dueño/guía. Retirar la pertenencia requerida
bloquea la transacción sin gasto; el viaje nativo a MAP02 conserva los registros
y permite reconstruir la presentación de la prueba allí.

Entorno: GZDoom 4.14.2, Freedoom y llvmpipe en Linux; escenarios controlados,
no una repetición completa de campaña ni un guardado del autor. El autor
confirma posteriormente que todas las pruebas de 0an dieron correcto. Auxiliares, partidas y motor de QA quedan
fuera del delta. Aplicación e instrucciones en PRUEBAS_4_33_0an.txt.

Entrega sobre el proyecto completo 0am con README y cinco documentos canónicos.
Su aceptación habilita la integración final 0ao antes de iniciar las bases
de ubicaciones/conexiones/viajes de 4.34.

## Base aceptada: 4.33.0am — conversación inactiva y extremos del Diario

La captura del log de 0al muestra fase 80, Caja propia válida, requisitos
cumplidos y esencia accesible a 32,6 MU. No hay canalización ni recarga.
ConversationNPC conserva un actor, pero su bInConversation vale falso. La
captura rechazaba cualquier referencia, aunque ya no hubiera diálogo activo.

0am comprueba la actividad real del interlocutor al abrir la esencia y al
esperar el cierre antes de animarla. Aplica la misma regla a la puerta, al
fundido de salida y a la Voz de llegada. No borra referencias nativas ni
repara el progreso: siguen siendo necesarias la Caja propia y la elección
explícita de capturar; abrir o cancelar el diálogo no entrega la carta.
Se conserva la entrega única y la bonificación existente de El Loco.

Izquierda/Derecha recorre los filtros y las misiones conocidas. Desde el
primer elemento, Izquierda pasa a la solapa anterior; desde el último,
Derecha pasa a la siguiente. Inventario: Tarot/Personaje. Misiones:
Oficios/Reputación. Con una sola misión, ambas flechas salen hacia su solapa
adyacente. Al volver se conserva la selección. RePág/AvPág o LB/RB cambia
de solapa directamente; Arriba/Abajo y F/Y mantienen sus otras funciones.
Las ayudas en español e inglés explican los extremos en una segunda línea.

### Evidencia y validación de 0am

Se reproduce de forma controlada el estado que informa el log: referencia
de un NPC cuyo diálogo ya está cerrado. En las fuentes originales 0al,
Usar no abre la esencia. Con 0am, la misma entrada nativa abre El Loco y
Enter completa la captura, también después de agotar Quintaesencia.
La Caja se recibe por el diálogo real de Palomo, sin darla directamente.
El escenario comienza después de las cuatro pruebas de residentes; no es
una ejecución completa de la misión ni usa un guardado del autor.

Veintiocho comprobaciones del Diario pasan por eventos SDL de teclado y el
despachador nativo: filtros, ambos extremos, una y tres misiones, huecos de
entradas desconocidas, Detalle, selección retenida, RePág/AvPág y ausencia
de aceptación automática. Las repeticiones por idioma no suman casos distintos.
Doce comprobaciones del tramo Palomo/Caja/agotamiento/captura confirman el
arreglo sobre el estado reproducido, identidad y entrega única con +2%.

Diecisiete comprobaciones adicionales pasan al cargar con 0am un guardado
nativo creado por 0al con referencia inactiva, en las coordenadas comunicadas:
Caja y atributos conservados, ausencia de captura al cargar, protección de
un interlocutor activo, Usar, cancelación con Esc y nueva confirmación.
La animación termina aunque se conserve otra referencia inactiva a la esencia.
La puerta abre y el fundido llega a MAP02 aun con una referencia inactiva al
umbral; sobreviven carta, Caja y primera arma y se abre la Voz de llegada.
El arma y su registro se preparan sólo para verificar el contrato de salida;
esta prueba no repite el crafting. No se modifican los archivos del guardado.

El motor compila las fuentes sin errores y pasa validate_project.py: cinco
documentos, 74 archivos de audio y 12 modelos de estación. El delta contiene
12 archivos nuevos/modificados. Entorno: GZDoom 4.14.2, Freedoom y llvmpipe en
Linux. La comprobación del autor en Windows queda pendiente. Los auxiliares
de pruebas, el motor y el IWAD no forman parte del parche.

Entrega delta sobre 0al con README, cinco documentos canónicos y
PRUEBAS_4_33_0am.txt. Mapas, assets, atributos y protección/restauración de
infraestructura conservados. El autor acepta estos ajustes antes de 0an.

## Base 4.33.0ak — captura observada; controles revisados en 0al

El autor informa árboles y estaciones desplazados por Quintaesencia, bloqueo
al capturar la esencia y controles del Diario que cambian filtro/solapa en
vez del destino esperado. No se da por aprobado 0aj. Se conserva la base de
misiones opcionales y se priorizan estas correcciones antes de reputación.

La selección del sello aceptaba infraestructura porque también es SHOOTABLE.
0ak excluye CaelumMovableProp del área de los sellos, incluida la masa atrapada
y la expulsión. MAP01 reubica una sola vez las mismas plantas y estaciones:
origen del jardín y disposición vigente de las habitaciones. No recrea los
nodos ni sus existencias; conserva sus referencias, tareas y reservas.
También limpia velocidad y suspensión indebidas de objetivos guardados.

La captura normal se reprodujo funcionando en las fuentes originales 0aj.
El bloqueo reproducido aparece al canalizar: PlayerThink descartaba Usar.
Una pulsación nueva de Usar ahora detiene el canal, aplica su recarga normal
y llega a la interacción nativa en esa misma pulsación. El Loco conserva
el requisito de Caja propia y la confirmación del diálogo para la entrega única.

Diario: Izquierda/Derecha cambia de misión en Misiones; en Inventario cambia
de solapa directamente. F/Y conserva el filtro del inventario. RePág/AvPág
o LB/RB cambia de solapa en cualquier sección. Las flechas de una estación
abierta conservan sus recetas; salir de Oficios cierra la sesión nativa y
detiene el trabajo atendido. Las ayudas se actualizan en español e inglés.

### Validación técnica de 0ak

GZDoom 4.14.2 con Freedoom y llvmpipe en Linux. Escenarios aislados sobre las
fuentes del parche; los auxiliares y recursos del motor no se entregan.

- 78 comprobaciones de objetivos: infraestructura real de MAP01 excluida,
  árboles y estaciones inmóviles con Aire/Quintaesencia, gravedad restaurada
  y continuidad de atracción/masa/expulsión para objetivos de combate.
- 34 comprobaciones del Diario: diez filtros, navegación circular entre
  misiones, Detalle y cancelación de abandono, teclas de solapa y cierre
  nativo de una estación real. Se invoca la misma ruta de códigos de tecla
  usada por InputProcess y sus eventos nativos; teclado/mando físico pendiente.
- 19 al cargar una partida guardada por las fuentes originales 0aj con
  Quintaesencia activa y plantas/estaciones desplazadas: posición, identidad,
  gravedad, existencias parciales, rendimiento fraccionario, atributos,
  elecciones, 1,25 litros, Caja, misión terminada y recompensa conservados.
  Usar corta el canal y abre El Loco; confirmar concede una carta y sólo
  su +2% vigente. Repetir captura o recompensa queda rechazado.

Las 131 comprobaciones distintas pasan sin fallos. La interfaz se revisa en
ambos idiomas, sin sumar las repeticiones de los mismos controles. No se ha
recibido el guardado del autor: la compatibilidad usa un guardado nativo
preparado para reproducir sus síntomas. No representa una partida completa.
Aplicación y aceptación en Windows: PRUEBAS_4_33_0ak.txt. Mapas, arte, audio,
modelos y fórmulas de atributos se conservan respecto de 0aj.
El validador del proyecto pasa sin errores: cinco documentos, 74 archivos de
audio, 12 modelos de estación y referencias. El delta contiene 12 archivos:
cinco de ejecución, README, cinco documentos y un TXT de aplicación/pruebas.

## Base 4.33.0aj — observaciones corregidas por 0ak

0ai queda aprobado por el autor. Se conservan todos los atributos, incluidos
Resiliencia para Sueño y los divisores de consumo/regeneración de Constitución.
La auditoría anterior queda registrada para una revisión futura.

0aj implementa la base de misiones opcionales: oferta, requisito de otra misión
completada, aceptación explícita, objetivos limitados por su meta, completar,
fracasar y abandonar con confirmación. Un final no se sobrescribe ni se
reinicia. La recompensa usa Inventory nativo y un registro de entrega por
misión; si la recepción falla queda pendiente, y retirar el objeto no la repone.

El Diario selecciona entre misiones conocidas y muestra Detalle de la elegida.
La cadena de diagnóstico se habilita con give CaelumDebugQuestTrial: Recorrido
seguido de Espera. Está separada del contenido narrativo: constancias sin peso,
precio ni atributos, sin alterar la misión principal, Tarot o recursos T1.
SYSTEMS.md define reglas y límites; PRUEBAS_4_33_0aj.txt explica el recorrido.

Tras resolver la captura y aceptar los controles, el siguiente bloque conecta reputación
con condiciones reutilizables. Después
se revisará la integración antes de V4.34. Las balas y la potabilización siguen
pendientes de definición para ampliaciones posteriores. Calendario V4.35
precede Descanso; V5.0 conserva el refactor de programación.

### Validación técnica de 0aj

119 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 con Freedoom y
llvmpipe en Linux. Se conserva la evidencia del trabajo recuperado y se vuelve
a ejecutar el flujo y la interfaz sobre las fuentes finales; las repeticiones
del mismo escenario no se suman como comprobaciones adicionales.

- 70 del ciclo de vida: descubrimiento sin aceptación, requisito de la cadena,
  índices y objetivos inválidos, límites de progreso, finalización explícita,
  fracaso, abandono, finales permanentes y recompensa nativa única. Retirar
  la constancia no reabre el cobro; una recepción rechazada admite reintento.
  MAIN_M00 conserva su estado y sus setters rechazan alterar un final.
- 13 del Diario en español y 13 en inglés: selección circular, detalle de la
  misión elegida, oferta bloqueada, eventos nativos de aceptación/abandono,
  cancelación de confirmación y actualización de la pantalla. Capturas de
  lista, detalle y finales revisadas. Los escenarios invocan la navegación y
  los eventos de red del motor; el teclado/mando físico se verifica en Windows.
- Ocho al cargar una partida creada con fuentes originales 0ai: registro y
  etapa principal, ampliación de la instantánea del Diario, atributos,
  1,25 litros de la cantimplora y elecciones de sello/amuletos conservados.
  Las ofertas nuevas no aparecen hasta habilitar la prueba explícitamente.
- Ocho al recargar un guardado 0aj con Espera parcial: tiempo, objetivo,
  recompensa anterior y misión principal conservados, continuación y entrega
  única del segundo encargo.
- Siete en un ChangeLevel real MAP01 -> MAP02: viajan la constancia, el
  registro de cobro y el contador activo; se completa y cobra en destino sin
  duplicar la recompensa previa.

Los escenarios preparan perfiles y objetivos para aislar cada condición;
no representan una partida completa, el cruce narrativo del Limbo ni una
validación cooperativa. Se mantienen los límites de la observación de salud
descritos en SYSTEMS.md. Queda la aceptación del autor en Windows mediante
PRUEBAS_4_33_0aj.txt.

El validador del proyecto pasa: cinco documentos, 74 archivos de audio,
12 modelos de estación y referencias conservadas. Se comprueba el delta
contra la base 0ai recuperada y cotejada con su ZIP guardado. Los tres WAD,
los recursos audiovisuales y los cálculos de atributos conservan sus bytes.
Entrega: 15 archivos nuevos/modificados y un TXT de aplicación/pruebas.
CRC y reconstrucción exacta del contenido del ZIP comprobados.

## Base 4.33.0ai — aprobada por el autor

El autor corrigió su indicación anterior: Sueño pertenece a Resiliencia.
0ai restaura esa asociación conservando el divisor Tipo 4 (1 a atributo 0;
3 a 100). Constitución controla Hambre/Sed y ahora divide también su gasto al
regenerar vida/Aire, sin repetir el factor de masa del consumo pasivo.
Las velocidades no cambian. Se mantiene el umbral crítico <=10% restaurado
en 0ah y la piscina, recarga parcial y sorbos aprobados de 0ag.

La auditoría de los doce atributos está en SYSTEMS.md: familias coincidentes,
efectos activos, diferencias de escala/asignación y funciones pendientes.
La tabla del autor permanece como intención de diseño; la matriz auditada no
da por terminados los campos que sólo están calculados. No se implementan
automáticamente sus diferencias en este parche. Se actualizan Ronnie en ambos
idiomas, README y cinco docs, sin crear más documentos canónicos.

Una partida previa actualiza los factores sin reiniciar reservas, elecciones
ni progreso. Entrega delta sobre 0ah más un TXT de pruebas. Tras aceptar 0ai,
cerrar la revisión del tutorial y continuar fundamentos de mundo/viajes, sin
ampliar mapas. Quedan las discrepancias de atributos registradas abajo,
tratamiento de aguas inseguras y composición/proceso de balas. Calendario
precede Descanso; V5 mantiene el refactor de arquitectura de programación.

### Validación técnica de 0ai

95 comprobaciones nativas aprobadas en GZDoom 4.14.2, Freedoom y llvmpipe en
Linux: independencia de Constitución/Resiliencia/Paciencia, curva 0/50/100,
masas 50/100/200, atributos fraccionarios y límites, consumo pasivo real y
actualización de factores. Se comprueban cantidades y costes reales de ambas
regeneraciones, tope máximo, reserva insuficiente, ausencia de doble masa y
regla crítica para las tres reservas a 1/10/10,1 puntos.

Otras ocho comprobaciones aprobadas cargan un guardado creado con los archivos
originales de 0ah y un perfil normal con Paciencia distinta de Resiliencia.
Verifican factor y coste nuevos, conservación de atributos/reservas/litros y
elecciones y ausencia de división acumulada. Total: 103 comprobaciones nativas,
sin fallos. La preparación del guardado se comprobó también con la fórmula
original; no se editó el archivo guardado para simular compatibilidad.
El validador documental/de recursos termina sin errores, con cinco documentos
canónicos. Entrega de diez archivos, sin recursos binarios ni código de prueba.
El autor confirmó que todas las pruebas de 0ai fueron correctas. Los atributos
quedan como están; las diferencias de su auditoría se posponen.

### Validación técnica de 0ah

96 comprobaciones aprobadas en GZDoom 4.14.2, Freedoom y llvmpipe en Linux.
88 comprueban la curva en 0/50/100 con Constitución y Paciencia independientes,
masas 50/100/200, atributos fraccionarios y límites, consumo nativo de un segundo,
refresco de factores antiguos, umbrales 0/1/2/9,9/10/10,1/50 para las tres
reservas, daño combinado y bloqueo de regeneración. La piscina, la recarga
parcial y el sorbo aprobado de 0ag también pasan su regresión.

Se creó un guardado con código original 0ag, atributos 100 y factores cero;
otras ocho comprobaciones lo cargan con 0ah y verifican consumo positivo sin
reiniciar reservas, atributos, litros o elecciones. El divisor no se acumula.
El validador documental y de recursos terminó sin errores. La atribución a
Paciencia y los costes de regeneración se sustituyen ahora por 0ai; estas
pruebas anteriores son evidencia histórica, no aceptación del autor de 0ah.

### Validación técnica de 0ag

161 comprobaciones nativas aprobadas en GZDoom 4.14.2 con Freedoom y llvmpipe,
Linux. El bloque de agua suma 153: los seis modelos a 50/100/200 kg, volumen
por sorbo y remanente, diez pulsos reales durante diez segundos, piscina de
MAP01 con/sin recipiente, recarga parcial y límites de carga/Caja, daño a Sed
cero, regeneración a 1 y 2 puntos y reglas previas de Hambre/Sueño.

Otras ocho comprobaciones cargan un guardado creado con el código entregado
0af: litros, efecto de bebida pendiente, progreso y elecciones/cupo de plata
conservados; nuevo sorbo ajustado a masa y recarga/hidratación real en piscina.
La prueba aísla el prólogo para que su diálogo automático no pause el tiempo.
El validador de documentación y recursos terminó sin errores. El autor aprobó
todas las pruebas de 0ag; la regla de Sed positiva se revierte en 0ah a su pedido.

### Validación técnica de 0af

GZDoom 4.14.2 con Freedoom, renderizado por software en Linux: pasan las
combinaciones de las cinco elecciones de sello por cuatro amuletos, los seis
recipientes, fórmula por masa, entrega de Ronnie, plata limitada, fabricación
personal y persistencia. Se cargó además un guardado generado con el código
original 0ae y se terminó su sello pendiente antes de elegir los accesorios.
Los menús nativos se recorrieron en español e inglés. Sprites RGBA revisados
como imágenes; las pruebas posteriores del autor aprobaron estos recursos.
El validador documental y de recursos termina sin errores.

## Base 4.33.0ae — aprobado por el autor

El autor confirmó que todas las pruebas de 0ae fueron correctas.
La base completa de 0ae fue recuperada desde los adjuntos del autor.

El autor aprobó todas las pruebas de 0ad. Caella ofrece enseñar los cinco sellos
T1 y sus componentes después de completar su prueba. Leer o posponer no cambia
el personaje; aceptar habilita conocimiento y cupo opcional para uno de cada
elemento. Usa las recetas existentes, sin cambiar costes ni efectos de Channel.

El conjunto al 100% en cada capa requiere 1,8 kg cobre bruto, 0,2 kg estaño bruto
y 0,6 kg de cada gema. El cupo se suma al del equipo elegido sin reiniciar lo
ya emitido. Si hay un sello T1 propio al aprender, sólo se presupuestan los
que faltan; el préstamo de Caella no cuenta. Esa existencia inicial queda
registrada: fabricar o perder una pieza después no repone el cupo.

Fabricación recursiva nativa desde materias primas, resultado personal sin Caja,
una ranura equipada y Detalle 0/5–5/5. El Banco de Trabajo de Caella y el taller
completo del segundo piso tienen la infraestructura. Ronnie puede prestar otra
vez la espada para los materiales de sellos pendientes, incluso con su misión
y reparación completadas, y acepta la devolución por su charla de talleres.

No agrega requisitos de misión ni cambia runas, historia de la salida o lo
que sale del Limbo. Mapas y audiovisuales conservan sus bytes. Se aplica sobre
0ad por copia de archivos más PRUEBAS_4_33_0ae.txt. Validación al final de este
documento. Próximo bloque de sistemas: recolección/potabilización de agua;
la composición y el proceso de balas todavía necesitan definición del autor.
Calendario/descanso y arquitectura V5 conservan su lugar en el roadmap.

## Base 4.33.0ad — aprobada por el autor

El autor aprobó todas las pruebas de 0ac. Ronnie pregunta qué familia de
armadura se desea después de elegir arma: mágica, liviana, mediana o pesada,
con descripción y confirmación. Enseña las cuatro piezas T1 y componentes;
quien ya eligió arma puede acceder por su conversación sobre talleres. No
obliga a repetir misiones ni añade un requisito al Toro o a la salida.

Se sustituye el abastecimiento al 25% por un cupo finito al 100% en cada capa:
un arma elegida, un conjunto elegido y diez flechas/virotes cuando corresponda,
al talle elegido. Cuero M: conjuntos 5/10/20/40 kg, más 6 kg si el arma son
los guanteletes gigantes. Cada fuente descuenta el mismo cupo por personaje.
El Toro conserva su rendimiento físico máximo, pero comparte cupo con el cajón.
Pilas anteriores también respetan el límite al recoger; las nuevas no generan
excedentes. La recogida parcial y el cofre dejan un gramo libre de capacidad.

Los inventarios anteriores no se borran al actualizar: cuentan al 100% junto
con componentes y primera arma ya hecha. El cajón permite dejar sobrantes sin
reservar. Las tareas anteriores mantienen eficiencia, tiempo y reservas. La
práctica opcional de reparación habilita sólo el faltante proporcional del daño
observado; no repone un lote completo. Se puede pedir y devolver la espada de
recolección para esa práctica. Fabricación, equipo y progresión nativos.

Aplicar sobre 0ac: archivos nuevos/modificados y PRUEBAS_4_33_0ad.txt, sin
aplicadores ni PK3. README y cinco documentos actualizados. Próximo bloque:
enseñanza de sellos T1 y sus cupos; balas necesitan composición/proceso y el
agua su recolección/potabilización. Mapas nuevos diferidos; V5 mantiene refactor.

## Base 4.33.0ac — aprobada por el autor

El autor aprobó todas las pruebas de 0ab. Se incorpora fabricación de virotes:
Ronnie enseña la receta y dependencias al elegir ballesta. También se incorpora
al conocimiento de guardados con esa elección, dentro y fuera de MAP01. No da
munición, materiales ni otro préstamo, y no cambia la primera arma elegida.

Receta 130, anexada a las 130 anteriores. Diez virotes nativos de 50 g por lote;
se adopta la misma estructura T1 de flechas: 70% asta y 30% punta de bronce.
Merma y tiempo de cada capa se calculan por las reglas vigentes, sin otros
materiales. Banco de Trabajo de Ronnie o segundo piso, filtro Municiones.
Salida personal sin Caja obligatoria, reservas y tareas nativas. Guía en el
apartado de taller de Ronnie y en Detalle para quien eligió ballesta.

Aplicar sobre 0ab con src, docs y README.md. Sólo archivos nuevos/modificados
más PRUEBAS_4_33_0ac.txt. Los mapas y recursos audiovisuales se conservan.
Siguiente cobertura: adquisición de recetas de armaduras/sellos T1. Las balas
necesitan definir composición y procesamiento antes de su receta; no se deduce
una receta completa de su masa actual de 3 g. Agua requiere su mecánica de
recolección/potabilización. Calendario/descanso y arquitectura siguen en sus hitos.

## Base 4.33.0ab — aprobada por el autor

El autor aprobó todas las pruebas de 0aa. Se implementa el siguiente tramo
pendiente de Ronnie: respiración en la piscina existente, detrás de la mansión
al este. Leer la propuesta no inicia; aceptar habilita una práctica opcional.
Sumergir la cabeza un segundo cerca de los escalones registra gasto real de
Aire. Volver a sacar la cabeza y completar la devolución submarina nativa de
tres segundos registra recuperación. Detalle y Ronnie reconocen cada fase.

El registro persiste durante inmersión, recuperación y después de completarla.
Mojarse sin cubrir la cabeza, nadar antes de aceptar o rellenar Aire por debug
no sustituyen los eventos. No se exige cruzar la piscina ni volver con Ronnie.
No modifica recursos, costes, geometría, requisitos de Rulo o salida.
MAP01 continúa como entorno de pruebas; nuevos mapas siguen diferidos.

Aplicar sobre 0aa combinando carpetas. Sólo archivos nuevos/modificados y
PRUEBAS_4_33_0ab.txt. Evidencia de validación más abajo.

## Base 4.33.0aa — aprobada por el autor

Los Menores suman sólo atributos base por palo/rango antes del porcentaje de
colección. Un palo completo da +3 a sus tres atributos. Espadas: mentales;
Copas: sociales; Bastos: físicos; Oros: técnicos. El registro de 78 índices
conserva propiedad; el Diario separa pasiva y colección. El Loco sigue siendo
la única carta obtenible en el contenido actual; no se adelantan otras misiones.

Zoom añade barrido de 360° a espadón, hacha de guerra y alabarda por triple
Aire del primario, conservando daño, alcance y recuperación. Un impacto por
enemigo, con geometría y aliados respetados; guanteletes mantienen bloqueo.
Daño general recibido y coste de Ánima dividen por Tipo 4 de Dureza/Elocuencia.
A 100, divisor 3. Colisiones, Dolor y Lucidez conservan las reglas anteriores.
Se reconstruyen estadísticas antiguas al cargar sin duplicar bonos/progreso.

Aplicar sobre 0z combinando carpetas. Entrega sólo archivos modificados más
PRUEBAS_4_33_0aa.txt; el validador acepta ahora sufijos de varias letras.

## Base 4.33.0z — incluida en la base 0aa aprobada

Base 0y aprobada: el autor confirmó que todas las pruebas dieron correcto y
que el desacuerdo informado era un error de interpretación. No se aplica una
reparación de estados de misión ni se cambia el modo de atributos en 100.

Tramo D de Ronnie: carga. Diálogo con peso, capacidad y factor de Aire por
carga reales. Práctica opcional: aligerar mediante soltar un sobrante o guardarlo
en la Caja si reduce el peso. Excluye la primera arma. No entrega objetos,
impone sobrecarga, altera costes o añade un bloqueo. Consume la misma interfaz
de inventario; préstamos y reservas mantienen sus reglas. Guardados y viaje
conservan el resultado. MAP01 sigue siendo el entorno de pruebas de sistemas.

Aplicar src, docs y README.md sobre 0y, combinando carpetas, y reconstruir con
run_dev.bat. PRUEBAS_4_33_0z.txt contiene sólo las comprobaciones nuevas.

## Base 4.33.0y — aprobada por el autor


Base: 0x completo, todas las pruebas aprobadas por el autor. Continúa el tramo
C del tutorial de supervivencia: Aire y movimiento. Construcción de mapas y
ampliación de alcantarillas siguen diferidas; MAP01 es el entorno de pruebas.

Ronnie ofrece la práctica después de devolver la espada. Aceptar registra un
objetivo equivalente al 1% del Aire máximo actual, sin modificar recursos.
El gasto nativo al correr y moverse acumula la primera parte. La recuperación
natural posterior acumula la segunda. No exige agotarse, una ruta concreta,
volver con Ronnie ni completar para seguir la misión. El estado parcial y los
resultados se conservan en el Inventory persistente. Detalle muestra qué falta.
Bebidas, ataques, saltos, inmersión y restauraciones de depuración no sustituyen
los dos puntos observados. No cambia costes, ritmos o recursos del mundo.

Aplicar src, docs y README.md sobre 0x, combinando carpetas, y reconstruir con
run_dev.bat. PRUEBAS_4_33_0y.txt contiene las pruebas nuevas.

## Base 4.33.0x — aprobada por el autor


Base: 0w completo, incluido el acumulativo desde 0u. El autor descargó y aprobó
TODOS esos cambios. La rectificación anterior de entrega queda resuelta.
Prioridad confirmada: sistemas y mecánicas según roadmap, usando MAP01 para
pruebas. Construir mapas y ampliar las alcantarillas queda diferido.

Ronnie enseña alimento/agua después de devolver su espada. La propuesta requiere
confirmación; sólo entonces ajusta reservas superiores al 90% una vez y entrega
una ración de cada tipo. Registra usos nativos bajo el 100%, sin exigir retorno
ni añadir bloqueos. Detalle muestra alimento y agua por separado. Si no puede
entregar por carga, reintenta únicamente la ración pendiente al pedírselo.
El refresco nativo de consumibles respeta diez segundos sin acumulación incluso
antes del parpadeo del efecto. Mapas, arte y audio no cambian.

Aplicar src, docs y README.md sobre 0w, combinando carpetas, y reconstruir con
run_dev.bat. PRUEBAS_4_33_0x.txt contiene sólo las comprobaciones nuevas.

## Base 4.33.0w — aprobada por el autor


**Base histórica del acumulativo 0w:** carpeta completa 0u.
La versión 0w fue aprobada por el autor.
El acumulativo incluyó 0v y 0w; posteriormente el autor aprobó ambas.
0w amplía el tutorial con una práctica opcional de reparación de Ronnie,
disponible después de devolver su espada. No exige repetir ramas ni añade
un bloqueo al cierre implementado. Se usa la primera arma real, por su ItemId.

Ronnie explica cómo inspeccionar el desgaste, seleccionar/desequipar la pieza,
usar el Banco de Trabajo del segundo piso y pulsar F en Oficios. La reparación
nativa conserva costes, materiales, eficiencias, tiempos y reservas. La práctica
se registra sólo al restaurar realmente esa pieza; hablar no la arregla, no
la daña artificialmente y no acredita una tarea iniciada/cancelada/pausada.
Detalle muestra el estado opcional. Guardar y viajar conservan su resultado.
Si se abandona la mansión sin hacerla, no se muestra un pendiente imposible.

El inventario de materiales T1 se auditó usando el catálogo vigente en GZDoom.
El cuello de botella es el cuero, no la presencia de las cinco gemas. Las
cantidades y límites están en SYSTEMS.md. No se aumenta el botín del Toro ni
el cajón autorizado para los guanteletes; tampoco se conceden recetas nuevas.
En ese hito faltaba distribuir recetas de armaduras/sellos. 0ad resuelve la
elección de armadura y 0ae incorpora enseñanza/cupos de sellos.

Los tres WAD, los sonidos, modelos y texturas mantienen sus hashes de 0v.
Quien ya salió puede continuar en MAP02; para probar esta ampliación se usa
un guardado anterior al cruce. No se abre un regreso artificial a la mansión.

### Cambios 4.33.0v incluidos y aprobados por el autor: salida y regreso al cuerpo

**Base:** carpeta completa 0u, con todas las pruebas aprobadas por el autor.
Se conservan la espada sin escudo fantasma, la defensa contextual de Rulo y
los bloques anteriores. 0v implementa el cierre de MAP01: fases 90 -> 95 -> 100.

Tras capturar El Loco, la salida responde al fondo de la sala del Toro, en
planta baja. Misiones > Detalle (F), Palomo, Ronnie y Rulo orientan hacia allí.
Sólo el portador de la Caja, con carta y pruebas completadas, puede activarla.
El aviso enumera qué se conserva y permite decir «No. Todavía no» sin cambios.
Una fabricación pendiente exige terminarla o cancelarla personalmente.

Confirmar inicia una breve transición guardable. Al finalizar se guarda la
primera arma por su ItemId dentro de la misma Caja; conserva tipo, tamaño,
esencia y condición. Se retiran los demás objetos físicos, incluidos los que
estaban almacenados. Se mantienen Tarot, recetas, personaje y recursos actuales;
al retirar equipo sólo se aplican los máximos que correspondan. El catálogo de
equipo adicional por clase y valores especiales al despertar siguen sin definir:
no se conceden piezas adicionales ni una curación gratuita.

La misión se completa antes del viaje nativo. MAP02 presenta una llegada breve
a las alcantarillas, con una plataforma seca, canal central, pasarelas y la Voz
que advierte al protagonista. Inventario permite recuperar y equipar el arma.
Todavía no incluye el recorrido completo, encuentros ni salida de alcantarillas.
MAP01 no tiene un camino de regreso normal desde esta llegada.

El campo de pruebas anterior se conserva como CADEV02, con el mismo TEXTMAP y
sus 16.508 cosas. Sus filtros de diagnóstico usan ahora ese nombre. MAP01.wad
permanece idéntico a 0u: el controlador retira el Exit provisional y presenta
la puerta al iniciar o cargar. Esto evita invalidar los guardados por cambiar
el checksum del mapa. No se reorganiza la arquitectura de programación de V5.

La colección de Tarot conserva el +2% fraccionario de El Loco, sobre los doce
atributos y sin acumulación al cargar. Las recetas y objetos siguen teniendo
una única fuente autoritativa; no se duplica la Caja ni el arma al reintentar.
El cruce actual es individual: ante otros jugadores presentes se informa y
no se inicia el traslado global. La salida cooperativa queda en el roadmap.

La base 0n aprobada incluye:

- Las 38 estaciones conservan sus instancias: esquinas en dormitorios y una
  fila de doce contra la pared del fondo del segundo piso. Puertas y estaciones
  rechazan activaciones desde otro nivel o sin línea de visión.
- Tab cierra Oficios, también durante una tarea; G filtra. Cerrar pausa la tarea.
- Arco y arco largo enseñan diez flechas por lote y sus componentes, usando
  crafting e inventario nativos. No consumen el lugar de la primera arma.
- Cinco vetas de gemas al fondo de la cueva. El cajón conserva sólo cuero T1.
  El abastecimiento histórico de 96 kg M para guanteletes al 25% queda
  sustituido en 0ad por el cupo del equipo elegido al 100%.
- Toro colocado tras la puerta de plata y Argento como custodio de la llave.
  La entrega exige las preparaciones con los cuatro: las prácticas de Rulo
  preceden al Toro. El presupuesto de cuero por recetas de 0n queda sustituido
  por el rendimiento basado en masa de 0q.
- Palomo corre visible por quince puntos, abre las puertas libres necesarias
  y sube por ambas escaleras hasta la habitación del segundo piso. No se
  teletransporta ni desaparece; continúa desde su punto al cargar.
- Indicación compartida neutral sobre la pared marcada y diálogos de recursos
  actualizados. Se conserva la devolución del bastón ante Caella de 0m.

Reparación, alimento/agua, Aire/movimiento, carga y respiración en piscina están
implementados como prácticas opcionales. Virotes y su conocimiento están
aprobados en 0ac. Elección de armadura y cupos al 100% aprobados en 0ad.
0ae incorpora recetas/cupos de sellos. Quedan composición y receta de balas y
recolección/potabilización de agua; no bloquean las ramas aceptadas.

Se conservan el WAD de MAP01, audio, modelos, jardín y poses aceptados. Las estaciones
siguen ofreciendo infraestructura T2; ese alcance no obliga a abastecer T2.
Formato: archivos nuevos/modificados para copiar, más un TXT de pruebas.
La migración 0h aceptada se conserva; V5 reorganizará el código de programación.

## Premisas permanentes

1. Código, identificadores y README general en inglés; comentarios explicativos
   y documentación de trabajo en español. Fuentes documentales de texto UTF-8;
   mantener formato monoespaciado en las exportaciones de documentación personal.
2. Preferir funciones nativas estables de GZDoom 4.14.2. Mantener una sola fuente
   autoritativa para datos y una arquitectura compartida entre armas y actores.
3. El producto final debe ser independiente: no distribuir assets de Doom.
   Mantener procedencia, atribuciones y modificaciones de los recursos propios
   o externos. Las dependencias de desarrollo no equivalen a autorización de distribución.
4. No inventar valores de balance, recetas, historia ni decisiones pendientes.
   El diseño del autor y sus correcciones posteriores fijan esos datos.
5. Proteger lo ya aceptado y validar sólo lo afectado por una revisión.
   Distinguir análisis estático, prueba aislada del motor y aceptación del autor.
6. Entregar únicamente archivos nuevos/modificados para copiar y pegar, más
   un TXT con aplicación y pruebas necesarias; sin instaladores del parche.
   No incluir IWAD, ejecutables, fixtures de prueba ni un PK3 completo como si
   fuera la base definitiva cuando sólo se dispone de un delta.
7. **Documentación consolidada y actualizada en cada parche.** README.md es la
   entrada general y se revisa con cada entrega. Mantener estos cinco archivos
   de `docs/`; integrar temas nuevos en sus capítulos antes de crear otro archivo.
   Un nuevo documento permanente sólo se justifica si el autor lo requiere.
8. Cada entrega actualiza versión, estado real, decisiones, próximos pasos y
   resultados de pruebas en el mismo cambio. No duplicar el estado entre un
   README por parche y varios informes temáticos. Las instrucciones temporales
   del ZIP quedan fuera de la instalación; las antiguas van al historial.
9. Conservar historia y contenido único. Antes de retirar un documento, integrar
   su información vigente y preservar el original. No eliminar silenciosamente
   archivos locales ni mantener requisitos obsoletos como instrucciones actuales.

10. **Carpetas con una responsabilidad clara.** Antes de retirar archivos,
    comprobar consumidores y procedencia. Conservar fuentes útiles en assets,
    empaquetar sólo src y respaldar retiradas conocidas. El TXT de pruebas
    de cada entrega no se acumula en los cinco documentos activos. V5.0 reorganiza el
    código mediante cambios pequeños con compatibilidad de guardado.

## Mapa de documentos

| Archivo | Responsabilidad |
| --- | --- |
| [README.md](../README.md) | Entrada en inglés, instalación y estado resumido. |
| [PROJECT.md](PROJECT.md) | Premisas, estado, plan y validación actual. |
| [SYSTEMS.md](SYSTEMS.md) | Reglas, controles, crafting, economía, Caja y diálogos. |
| [MAP01.txt](MAP01.txt) | Historia y especificación completa, precedidas por el alcance implementado. |
| [ASSETS.md](ASSETS.md) | Audio, arte, primera persona y referencias de atribución. |
| [HISTORY.md](HISTORY.md) | Registro de decisiones y documentos anteriores. |

Los avisos redistributivos de `src/licenses/` permanecen junto a los assets.
No son duplicados administrativos y la reorganización no los elimina.


## Roadmap inmediato: cerrar sistemas y pruebas en MAP01

Cada bloque termina con pruebas enfocadas y aceptación del autor antes de
ampliar el siguiente. La numeración de las correcciones intermedias depende
de lo que arrojen esas pruebas; no son plazos de entrega.

| Orden | Bloque | Alcance restante / criterio de cierre |
| --- | --- | --- |
| 0 | Base hasta 4.33.0n | Todas las pruebas aprobadas por el autor el 2026-09-11. Se conserva la migración 0h. |
| 1 | 4.33.0o: retiro del manual exterior | Entregado; el autor pidió proseguir con Rulo. Mantener la limpieza y las recetas aprendidas. |
| 2 | 4.33.0p–0r: Rulo/Toro | Resto de 0q aprobado. 0r corrige el diálogo poscombate y protege a los residentes; expresa liderazgo y fuerza innata. Todas las pruebas de 0r aprobadas por el autor. |
| 3 | 4.33.0s: Palomo final, fase 80 | Diálogo final y Caja única. Todas las pruebas aprobadas por el autor. |
| 4 | 4.33.0t: El Loco en la cueva, fase 90 | Captura, colección y +2% fraccionario implementados; resto de pruebas aprobado por el autor. Sus dos observaciones se corrigen en 0u. |
| 5 | 4.33.0u: escudo real y guía de Rulo | Todas las pruebas aprobadas por el autor. |
| 6 | **4.33.0v: salida y regreso al cuerpo, fase 100** | Implementado: confirmación, arma por ItemId en la Caja, limpieza final y llegada narrativa. Aprobado por el autor como parte del acumulativo 0w. Recursos actuales conservados; equipo adicional y valores especiales requieren definición posterior. |
| 7 | **4.33.0w: mantenimiento opcional y auditoría T1** | Reparación real de la primera arma con Ronnie, guardable y sin un nuevo bloqueo de misión. Materiales auditados; cantidades en SYSTEMS.md. Aprobado por el autor. |
| 8 | Ampliaciones restantes del tutorial | Alimento/agua, Aire/movimiento y carga 0aa, respiración 0ab y virotes 0ac aprobados. Elección/recetas de armadura y cupos al 100% de 0ad aprobados. Enseñanza/cupos de sellos de 0ae aprobados por el autor. 0af incorpora recipientes y recolección potable; el resto fue aprobado y las pruebas de 0ag también. 0ai restaura Resiliencia para Sueño y aplica Constitución al gasto de regenerar vida/Aire, conservando divisores y críticos de 0ah; todas las pruebas de 0ai aprobadas. Quedan composición/proceso de balas y tratamiento de aguas no potables. No se promete fabricar todos los conjuntos ni hacerlo al 25%. No bloquear ramas aceptadas. |
| 8a | Balance autorizado 0aa | Pasivas menores, barrido de armas grandes y divisores Tipo 4 aprobados por el autor. |
| 8b | Auditoría de atributos 0ai — pospuesta por el autor | Mantener los atributos actuales. Para una revisión futura, precisar recarga/cooldown por Elocuencia (munición hoy con Destreza; Channel fijo de 60 s) y escala de salto; completar duración de estados por Constitución, alcance de debuffs/buffs, curaciones de Empatía, mitigación general de necesidades por Paciencia, tareas académicas y sentidos ocultos de Perspicacia. Incluir Caja por Inteligencia y coste de Ánima por Elocuencia en la tabla vigente. Se documenta el estado real en SYSTEMS.md; estos efectos pendientes no bloquean 0aj ni el paso a V4.34. |
| 8c | 4.33.0aj: base de misiones opcionales | Ofertas, requisito entre encargos, aceptación, progreso limitado, finales permanentes y recompensa nativa única por misión. Dos encargos de diagnóstico activados expresamente, selección/Detalle y abandono confirmado en Diario. Aprobado por el autor: entrega de recompensas, bloqueo tras abandono y fallo al salir antes del objetivo. |
| 8d | 4.33.0ak–0am: correcciones de sello, captura y Diario | Infraestructura protegida/restaurada. El log de 0al identifica la referencia de conversación inactiva; 0am corrige su bloqueo y el salto de solapa en los extremos. RePág/AvPág conservado. Aprobado por el autor en 0am. |
| 8d.1 | 4.33.0an: reputación y condiciones | Implementadas condiciones reutilizables de diálogo, acceso y comercio, con prueba opcional accesible desde Reputación. Todas las pruebas aprobadas por el autor. Relaciones, rangos y asignaciones narrativas siguen sin inventarse. |
| 8e | 4.33.0ao: cierre de integración | Guardado combinado 0an, captura y salida narrativa hacia MAP02 comprobados; reanudación de conversación activa al cargar, informe explícito y roadmap actualizado. El autor autoriza continuar con 4.34.0a. Balas, potabilización y demás pendientes heredados pasan a V5; no se presupone una nueva repetición de todas las pruebas de 0ao. |
| 8f | 4.34.0a: ubicaciones y conexiones | Diario de mundo, lugares visitados y registro del regreso existente MAP01 → MAP02; guardados anteriores y conservación al viajar. Primer parche de 4.34, aprobado por el autor. |
| 8g | 4.34.0b: puertas y accesos por grupo | Requisitos nativos de todas las hojas, grupos independientes sin id, ocupación del paso y reapertura durante el cierre. Prueba opcional con llave propia y guardados anteriores. Aprobado por el autor. |
| 8h | 4.34.0c: alcantarillas conectadas | MAP02 enlaza con MAP03–05 para futuras pruebas masivas, Tarot y entorno. Seis sentidos, hub nativo, escaleras, Diario y guardados; ningún regreso a MAP01. |
| 9 | Construcción de mapas y alcantarillas | La ampliación de campaña pasa a V5 por decisión del autor. Durante V4, priorizar sistemas y pruebas; en 0m el autor autoriza extensiones de puerto/playa con sus texturas para continuar MAP03. Conservar la llegada de MAP02 y CADEV02. |

La verdad autoral y las revelaciones futuras no deben filtrarse a los NPC del
inicio. MAP01.txt contiene la especificación completa y las correcciones que
prevalecen sobre su primera versión.

## Roadmap general por versiones

Esta es la secuencia ya planificada, reconciliada con lo implementado. Los
registros originales siguen completos en HISTORY.md. “Base implementada”
no significa que todo el contenido de ese sistema esté terminado.

Decisión del autor del 2026-09-13: completar el roadmap numerado de V4 hasta
4.37; después preparar y exportar una versión de prueba para otros jugadores;
sólo tras esa exportación iniciar V5. Todo el trabajo heredado y transversal
pendiente pasa expresamente a V5. No se añade un bloque 4.38 ni se exige
terminar la campaña completa para exportar la prueba.

La autorización actual permite continuar desde el cierre técnico 4.33.0ao a
4.34.0a; no se registra como una nueva afirmación de que el autor haya repetido
todas las pruebas de 0ao. Cada parche mantiene sus comprobaciones enfocadas.
Las bases incluidas en 4.34–4.37 conservan su alcance: sus ampliaciones de
contenido y los pendientes de versiones anteriores se retoman en V5.

| Hito | Estado y trabajo pendiente |
| --- | --- |
| V4.27: controles de combate | Rutas nativas implementadas: Fire/AltFire, Reload contextual, Zoom Block/ADS/barrido y User1–4. Matriz pendiente por familia trasladada a V5; conservar lo aceptado. |
| V4.28: Channel de Sellos | Efectos actuales sin clima aceptados en 0bp. Extensiones dependientes de clima pasan a V5; no reabrir los efectos cerrados. |
| V4.29–V4.31: crafting y ciclo de equipo | Base de recetas, reservas, lotes, eficiencias independientes, reparación y desarme aceptada. Distribución narrativa de conocimiento, recompensas/hojas/tiendas/descubrimientos y bonos de eficiencia sin valores autorizados pasan a V5. |
| V4.31: recursos, botín y contenedores | Fuentes físicas y alijos tienen base; en V5, completar tablas de botín por planta/animal/monstruo, contenido/capacidad/propiedad/robo/reposición de contenedores y adquisición sistemática de materiales. La expansión persistente de biomas va en V5. |
| V4.32: NPC, comercio y primera persona | Use/USDF, transacciones, monedas y Caja aceptados. Comerciante canónico posterior, contenido de tiendas y primera persona de las demás armas con arte propio pasan a V5. |
| V4.33: misiones, reputación y facciones | MAP01, base de encargos y condiciones reutilizables aprobadas hasta 0an. 0ao verifica la integración final y recupera el menú de conversaciones activas al cargar. Cadenas y recompensas narrativas amplias, condiciones compuestas, rangos y relaciones concretas pasan a V5; los cuatro ids técnicos no equivalen a las ocho facciones narrativas. |
| V4.34: arquitectura del mundo y viajes | 0a–0c aprobados: catálogo, Diario, regreso, puertas por grupo y alcantarillas conectadas. 0d implementa caravanas y registro compartido; 0e añade estaciones y suministros de prueba. El autor aprueba ahora todas las pruebas de 0e, incluido el bloqueo por sellos/crafteos y la recuperación de Use. MAP01 no admite retorno. Horarios, duraciones y eventos se integran con el reloj de 4.35. El refactor del código sigue en V5.0. |
| V4.35: calendario, clima y eventos | 0a–0g aprobados: reloj/calendario, Limbo, descanso, mobiliario/cámara, bolsa y comodidad. 0g implementa avance seguro, mesas/comida sentada y Lucidez del sueño. 0h añade digestión, repetición de raciones y mobiliario/talleres de MAP01; pruebas nativas realizadas. 0i–0j corrigen accesos/Use, ajustan estaciones/comidas y fijan Limbo 1:1; 0j y 0k aprobados por el autor. 0l corrige sillas/agua e incorpora clima regional SMN y cobertura geométrica. 0m escala comida por masa, confirma Buenos Aires y agrega puerto/costa de ensayo autorizados por el autor. 0n añade viajes medidos con provisiones; 0o integra agenda mensual y eventos persistentes definidos por el autor. 0n/0o aprobados salvo observaciones resueltas en 0p, que añade reservas, Q y vehículos costeros. 0p aprobado. 0q integra el paquete visual v4 y el ritmo de comida 1/3, pendientes de aceptación. Modelo térmico corporal en V5.1. |
| V4.36: entorno móvil y peligros físicos | Rocas que ruedan, objetos que caen y superficies peligrosas; luego avalanchas, arietes, catapultas y sectores móviles mediante el núcleo físico. Extraer Impact Physics como paquete independiente sólo tras cerrar su validación en Caelum. |
| V4.37: Tarot y Trucazo | Colección iniciada en 0t y pasivas base de los 56 Menores implementadas en 0aa; activación de cartas poseídas/seleccionadas con User3 y costes/cooldowns; después contenido de cartas y minijuego Trucazo sobre inventario/NPC/eventos estables. |
| **Exportación de prueba de V4** | Después de 4.37 y antes de V5: congelar una base identificable, preparar un paquete jugable para otros jugadores, instrucciones de instalación/controles, recorrido de prueba, guardados y registro de incidencias. Verificar arranque y ejecución desde el paquete exportado. La exportación no exige completar el contenido trasladado a V5 ni equivale a la distribución independiente final. |
| **V5.0: arquitectura modular del código** | Primer bloque de V5, después de cerrar V4 y exportar la versión de prueba. Separar responsabilidades, reducir CaelumPlayer a coordinación y migrar mediante adaptadores pequeños. Una implementación de inventario/jugador/Tarot; autoridad multijugador transversal. Preservar guardados, entradas y selectores. |
| V5.1: exposición térmica | Modelo de calor/frío basado en clima, zonas, actividad, humedad persistente, viento y equipo real; Resiliencia, consumibles, refugios, secado, descanso y aclimatación. Curvas numéricas pendientes de balance autoral. |
| V5.x: recursos y biomas marinos | Fuentes 3D persistentes, extracción cuerpo a cuerpo cortante/perforante, dureza/rareza/profundidad/región/habilidad, agotamiento y regeneración. Biomas marinos, algas/yodo y aguas no potables; tiendas mantienen acceso a materiales remotos. |

### Trabajo heredado y transversal: V5, después de la exportación

Todos los compromisos de esta tabla quedan asignados a V5 por decisión del
autor. También pasan a V5 la matriz de combate pendiente, aprendizaje y
bonificaciones de recetas, botín/contenedores/propiedad, comerciante y tiendas
posteriores, primera persona restante, ampliación de misiones/facciones,
auditoría de atributos pospuesta, composición de balas y potabilización.
Sus dependencias determinarán el orden interno; no se inventan números de
parche ni valores todavía no definidos.

Cuando un área comparte nombre con 4.34–4.37, V4 termina su base prevista y
V5 desarrolla el alcance amplio siguiente. La arquitectura del código se
reorganiza en V5.0; la exposición térmica mantiene V5.1. La prueba exportada
es un hito anterior, distinto de completar la distribución independiente.

| Área (V5) | Alcance planificado y límites actuales |
| --- | --- |
| Campaña y mundo | Objetivo de 78 cartas (22 Mayores y 56 Menores) y al menos 78 mapas; geografía inspirada en Argentina, costas/Antártida/mar profundo, ciudades aéreas y regiones sobrenaturales. Capítulos, encuentros, desenlaces políticos y revelaciones según canon. La primera entrega sigue concentrada en MAP01. |
| Misiones | Principales/secundarias, requisitos, objetivos, cadenas/dependencias, fracaso y abandono; recompensas de objetos/dinero/reputación/desbloqueos. El registro tiene 32 slots y ocho objetivos por misión; 0aj añade oferta y abandono a los cuatro estados originales, con requisitos y recompensas únicas. El contenido amplio, las condiciones compuestas y los demás tipos de recompensa requieren desarrollo. Mayores para principales, Menores para secundarias; encargos/eventos/rumores/contratos no son automáticamente otra carta. No introducir XP por combatir: la progresión canónica depende del Tarot. |
| Facciones y secreto | La Capital, Pueblos Libres, Nativos, Caelith Puros, Híbridos, Gendarmería, Culto del Tarot e Infierno. Siete rangos de reputación, relaciones cambiantes y consecuencias en precios, acceso, misiones, hostilidad y asedios; pertenencia/secreto del Culto como contenido futuro. |
| Diálogo social | Reputación aplicada a las tiradas y umbrales, emociones privadas, interrupción por combate/eventos y conversaciones con varios NPC en secuencia. MAP01 sólo usa los valores aprobados para su tutorial; no asignar facciones ni dificultad nuevas por defecto. |
| Viajes | Carreta, barco, submarino arcaico, aeronave, nave mágica y portales; encuentros, ataques, tormentas y fallos mecánicos. Tiempo global, localizaciones, rutas y cambios permanentes del mundo son dependencias. |
| Supervivencia y descanso | Acción Descansar con alimentos/bebidas y avance temporal; campamentos/propiedades/refugios, recuperación y calidad del descanso. Integrar exposición térmica; límites de oxígeno, altura, agua y futuras capacidades de respiración según las cartas. |
| Agua y simulación fuera de mapa | Extender marcadores de potabilidad a aguas marinas/contaminadas; red de volúmenes a niveles distintos es capacidad técnica aún no construida. Definir compensación de recursos/clima/eventos al volver a mapas descargados mediante calendario global. |
| Percepción y sigilo | PerceptionCore, sensores visuales/acústicos, sigilo, detección/pérdida/reencuentro/memoria y comunicación compartida. El diagnóstico de grupos/percepción no es la IA final; resolver campos de visión, fórmulas angulares, estados/tiempos, ruido por acción/superficie/cadencia y derivación de sigilo antes de asignar valores. |
| Grupos y acompañantes | Formación jugable, pertenencia dinámica, líderes de movimiento, offsets locales, sueño por distancia y memoria compartida. NPC de relleno para party incompleta: acompañar/combatir sin decidir diálogos. La base diagnóstica de grupo 16 no impone tamaño fijo a la formación visual. |
| IA masiva y rendimiento | Mantener presupuesto escalonado de percepción/objetivos y filtros espaciales; resolver locomoción compartida, contactos y pruebas graduales de 1.875 → 3.750 → 7.500 → 15.000 activos según el último gate aprobado. Cargar 15.000 actores pasivos no prueba 15.000 IA completas. |
| Asedios | Director de batalla, refuerzos, tácticas, comandantes, aliados, máquinas/artillería/barricadas, sabotaje y rutas alternativas; límite temporal y consecuencias permanentes sobre ciudades, rutas y facciones. Depende de IA, física, mundo y calendario estables. |
| Física | Completar validación de impactos/contactos múltiples, empuje sostenido, aplastamiento y anatomía/armadura. La futura física de golpes cuerpo a cuerpo requiere velocidad, masa efectiva, área/filo, material, penetración y técnica definidos; no reemplazar el combate aceptado sin ese diseño. |
| Habilidades | Efectos de User1 racial y User4 clase definidos el 2026-09-14 y registrados en SYSTEMS.md; Sueño del Arcanista implementado en 0g, resto pendiente. Peregrino usa Amparo (50% menos daño ambiental), no Bendecir los alimentos. User2 conserva Sellos; User3 conserva Tarot. No inventar poderes ni valores para llenar los hooks existentes. |
| Tarot | Colección persistente y porcentaje global iniciados con El Loco en 0t; pasivas base por palo/rango de todos los Menores en 0aa. Pendientes selección, activación y despertar de armas de esencia; cartas con efectos de exploración, respiración y Caja según diseño. Completar las 78, sus misiones y persistencia; no confundir un hook con poderes terminados. |
| Trucazo | Truco con Tarot: Mayores modificadores, Menores jugables/filas, Envido/Truco/Retruco/Vale 4, daño y vida, Sentidos Mágicos, apuestas y consecuencias; casual/ranked y equipos 1v1 a 4v4. Implementar por capas tras reglas base de Tarot y autoridad multijugador. |
| Cooperativo y PvP | Objetivo 2–8 jugadores, autoridad del anfitrión, propiedad/validación/sincronización, misiones y mundo compartidos, viajes, conexión/desconexión y compañeros. La persistencia individual actual no acredita estos modos. |
| Guardado | Mantener guardado nativo e Inventory viajero. Perfil externo independiente, autoguardado narrativo y estado compartido del mundo permanecen pendientes; ensayar compatibilidad antes de retirar adaptadores de V5. |
| Arte, audio e interfaz | Vistas de primera persona restantes, contenido visual de mapas, efectos/emisores por región/hora/clima y adaptación de stock a escenas. Conservar tipografía, iconos y rig aceptados; actualizar inventario y créditos con cada recurso. |
| Distribución independiente | Sustituir toda dependencia final de arte/audio/fuentes/mapas de Doom, completar atribuciones y empaquetado propio, validar arranque/guardado/mapas y modos de juego. El IWAD de desarrollo no entra en los parches. |

### Decisiones que todavía requieren diseño del autor

Balance completo de cartas, habilidades raciales/de clase, economía y recursos;
tablas/reglas de cosecha y botín; contenido y propiedad de contenedores; fuentes
definitivas de recetas/componentes; sensores y sigilo finales; clima regional,
encuentros y consecuencias de facciones; valores térmicos y física cuerpo a
cuerpo. Los documentos históricos contienen propuestas: se comprueba su
vigencia antes de implementarlas. La progresión ya aceptada no se reabre.

## Auditoría de carpetas 4.33.0h

Base: ZIP completo aportado por el autor, 16.626 entradas. Se verificaron CRC,
rutas, inventario y consumidores. La limpieza usa una lista explícita con
SHA-256 por archivo; “no aparece como texto” no alcanza para eliminar un
sprite, fuente, modelo o recurso que el motor resuelve por convención.

| Carpeta / entrada | Archivos de la base | Decisión y motivo |
| --- | ---: | --- |
| Raíz | 4 | README actualizado; build_dev.ps1 pasa a ser el único constructor Windows; run_dev apunta a él; se conserva la configuración del proyecto. validate_project.py se traslada aquí. |
| docs | 5 | Mantener los cinco documentos canónicos, integrar roadmap/auditoría y corregir el estado real de 0g. |
| tools | 74 | Retirar la carpeta activa: conservar constructor/verificador en raíz y tres generadores en assets. Los otros 69 archivos son utilidades de revisiones anteriores o constructores redundantes, preservados en el respaldo. |
| art_source | 20 | Trasladar todos los originales y registros a assets/source/art con las mismas huellas. |
| assets | 13 | Conservar atlas fuente y paquete 05 con README/checksums; añadir arte fuente y generadores. No se empaqueta en runtime. |
| src | 4.276 | Mantener recursos y módulos útiles; sólo se aplican correcciones de audio y créditos, más el observador de portada. La arquitectura del código se reorganiza en V5. |
| build | 1 | PK3 regenerable: reconstruirlo al aplicar. Se conserva el anterior hasta completar el reemplazo atómico; no acumular copias de 77 MB como fuentes. |
| archive | 1 | Conservar el respaldo de 0g y añadir un único respaldo verificado previo a 0h. Los registros históricos tienen utilidad de recuperación. |
| Historial Git | 11.803 | Conservar íntegro: contiene la historia de versiones, no archivos temporales de la entrega. |

Detalle de todos los directorios inmediatos de src, antes del parche:

| Entrada de src | Archivos | Utilidad comprobada / decisión |
| --- | ---: | --- |
| Lumps de raíz | 13 | ZSCRIPT, MAPINFO, SNDINFO, menús, USDF, textos y registros nativos: conservar y ajustar referencias de audio. |
| caelum | 59 | Módulos de gameplay y UI enlazados desde ZSCRIPT; añadir un observador UI, sin dividir/reubicar los módulos existentes. |
| impactphysics | 1 | Núcleo físico incluido por ZSCRIPT; conservar. |
| crafting | 1 | Catálogo de recetas cargado por el sistema; conservar. |
| maps | 3 | MAP01 invariable; llegada narrativa MAP02 y campo de pruebas preservado como CADEV02 desde 0v. |
| graphics | 556 | UI, iconos/texturas y registros de gráficos; conservar contenido y convenciones del motor. |
| hires | 1 | Recurso gráfico de alta resolución del proyecto; conservar. |
| sprites | 1.129 | Estados de actores/armas y sprites base de modelos; conservar, incluidos marcadores transparentes necesarios. |
| models | 155 | Geometrías/texturas/modelos enlazados por MODELDEF; conservar. |
| fonts | 2.280 | Glifos y conjuntos tipográficos; su resolución es nativa, no una referencia textual por carácter. Conservar. |
| sounds | 72 | Audio usado y reserva registrada; sustituir únicamente la frase derivada. |
| music | 2 | Música propia de MAP01/MAP02; conservar. |
| licenses | 5 | Avisos redistributivos necesarios, distintos de documentación administrativa; actualizar la modificación del arpa y las rutas de los generadores visuales. |

No se encontró basura temporal inequívoca adicional dentro de src. Los recursos
reservados para contenido futuro no se declaran inútiles. El manifiesto del
aplicador especifica cada retiro/traslado; archivos locales desconocidos se
conservan. Un archivo auditado que cambió desde el ZIP detiene la aplicación
antes de escribir y se informa con su ruta.

## Aplicación y mantenimiento

Con GZDoom cerrado, copiar src, docs y README.md sobre la carpeta
completa 0an y aceptar reemplazos. Combinar carpetas; no sustituir src por una
carpeta que contiene sólo el delta. Iniciar run_dev.bat para reconstruir y jugar.
El ZIP sólo contiene archivos nuevos/modificados y PRUEBAS_4_33_0ao.txt.

Se conservan build_dev.ps1 y run_dev.bat existentes: construyen el juego, no
instalan parches. Se mantiene la migración 0h aceptada y las rutas del motor/IWAD
del autor. No se entregan ni ejecutan más aplicadores por versión. El TXT de
pruebas queda junto al ZIP; sus resultados se integran en estos cinco documentos.

## Validación de 4.33.0ae

162 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
62 en español, 62 en inglés, 16 al actualizar un guardado auténtico de 0ad y
22 al recargar un sello pausado. Se cuentan sólo las comprobaciones nuevas
de cada recarga, sin volver a sumar los contadores guardados por las escenas.

Uso y elección en conversaciones USDF nativas: lectura, rechazo, aceptación,
guías, enseñanza antes de elegir arma y consulta después de completar Ronnie.
Las cinco recetas y dependencias se aprenden sin objetos gratis; recetas de
otras familias no se conceden. La suma de cupos conserva arma, armadura y
munición. Las fuentes reales emiten la cantidad restante y no vuelven a emitir
al agotarla. Para cada sello, su cupo al 100% coincide con las hojas reservadas
por el plan de fabricación nativo, sin Caja obligatoria.

Se fabricaron los cinco elementos y se equiparon uno por uno en la ranura
única. Detalle alcanzó 5/5. Se comprobó el inicio nativo de Channel con un sello
fabricado, gasto real de Adrenalina y cooldown. No se revalidó toda la matriz
de efectos elementales previamente aceptada. Pausa, cancelación, reanudación
y guardado mantuvieron materiales, cupos y salida única. Después se pudieron
fabricar la primera ballesta y diez virotes con sus materiales conservados.

El guardado antiguo se creó con fuentes 0ad, superponiendo después 0ae en la
misma ruta. Incluye primera arma, casco mediano, torso pendiente, cuero emitido,
lecciones completadas y un sello propio preparado en la escena. Aprender
reconoce ese sello y sólo agrega el cupo de los cuatro restantes; no vuelve
a descontar su coste del contador anterior. La tarea antigua conserva tiempo
y 10.000 unidades reservadas. Aunque la vista cambie a sellos, sigue dando el
torso correcto. Se completan los cuatro sellos faltantes y el préstamo/devolución
de la espada usa las páginas reales del taller de Ronnie, con reparación ya hecha.

Revisión visual de la guía de Caella y el árbol del Sello de Fuego en capturas
de 819×614: textos, icono, materiales, infraestructura y controles legibles.

El validador comprueba cinco documentos, 74 audios, 12 modelos de estaciones y
24 claves españolas de Caella, sin errores; las 13 claves nuevas tienen español
e inglés. El delta contiene 14 archivos modificados y el TXT nuevo. CRC y
superposición se verifican contra el árbol completo usado por el motor; mapas,
arte, modelos, música, sonidos y assets conservan sus bytes de 0ad.

Las escenas privadas preparan etapas, atributos, materiales y equipo, y adelantan
el tiempo con el helper diagnóstico existente. No sustituyen la ruta completa,
la espera de fabricación a tiempo real ni la prueba del autor en Windows.
0ad está aprobado por el autor; 0ae queda pendiente de esa aceptación.

## Validación de 4.33.0ad — aprobada por el autor

394 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
62 en español, 62 en inglés, 217 de familias/cupos, 15 al actualizar un guardado
auténtico de 0ac y 38 al recargar una fabricación de armadura pausada. Sólo se
cuentan las comprobaciones nuevas de las recargas, no sus contadores guardados.

Conversaciones USDF nativas: elección de arma, lectura de las cuatro familias,
confirmación de armadura, cajón y talleres. Se fabricaron y equiparon las cuatro
piezas de cada familia. Los cupos del arma se compararon con las reservas del
plan nativo para las 36 opciones y cinco talles (180 casos); el cuero del conjunto
se contrastó con las cuatro masas nativas en las 20 combinaciones familia/talle.
Ballesta, diez virotes y conjunto mediano consumieron sus materias primas exactas.

Extracción limitada antes de agotar la fuente o generar objetos, cupo compartido
entre arbustos, pilas antiguas, recogida parcial de pilas nuevas/antiguas con un
gramo libre, retirada/devolución del cajón y reparto Toro/cajón. La práctica de
reparación reservó y consumió el faltante proporcional al daño; pedirla de nuevo
no sumó otro lote. Préstamo y devolución de la espada conservan la primera arma.

La migración se probó creando el guardado con fuentes auténticas 0ac y
superponiendo 0ad en la misma ruta. Conservó recetas, primera arma, prácticas,
El Loco y una tarea de flechas al 25% con sus reservas y tiempo. Conservó los
96 kg de cuero anteriores hasta dejar voluntariamente el excedente en el cajón;
quedó el cuero útil para la armadura y no se tocaron componentes reservados.
La tarea antigua produjo una sola vez su munición antes de fabricar armadura.
Pausa, guardado, reanudación y cancelación de armadura mantienen cupos y reservas.

Revisión visual de la guía de Ronnie y el árbol de fabricación en capturas
de 819×614: textos y controles legibles. El validador comprueba cinco documentos,
74 audios, 12 modelos de estaciones y 24 claves españolas de Caella, sin errores.
El delta contiene 18 archivos modificados y un TXT nuevo; CRC y superposición
verificados contra el árbol completo utilizado por el motor. No cambia mapas,
modelos, sprites, música ni sonidos.

Las escenas privadas preparan etapas, materiales y atributos y adelantan tiempo
mediante el helper diagnóstico existente. Comprueban el proceso nativo y su
persistencia; no sustituyen una ruta completa ni la espera de fabricación a
tiempo real. El autor confirmó después que todas las pruebas de 0ad dieron
correcto; esa base queda aprobada para continuar con 0ae.

## Validación de 4.33.0ac — aprobada por el autor

129 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
47 en español, 47 en inglés, 17 al recargar una tarea pendiente, 2 tras guardar
su resultado, 9 al actualizar una tarea de flechas de 0ab y 7 al actualizar un
guardado 0ab que ya estaba en MAP02. Las recargas cuentan sólo las comprobaciones
nuevas, sin volver a sumar el contador persistido por la escena.

Elección real de ballesta por las páginas USDF de Ronnie, consulta de munición
y Detalle en ambos idiomas. Enseñanza de receta y dependencias sin objetos
gratis. En el Banco de Trabajo real se comprobaron lotes de diez al 25%, 50% y
100%, desde componentes y desde materias primas, con consumo de hojas del plan
y salida personal sin Caja. Reservas impiden descartar materiales; cerrar
pausa, guardar conserva tiempo/reservas y cancelar libera sin consumir.
Materiales insuficientes, receta desconocida y capacidad de pila insuficiente
no producen munición ni consumen materiales. La prueba de límite reduce el
máximo de pila sólo en la escena privada; el valor del juego no cambia.

Fabricación nativa de ballesta, recarga y disparo: se consume un virote y se
crea CaelumBoltProjectile; la pila de flechas se conserva. La munición no
acredita ni reemplaza la primera arma. El viaje de desarrollo a MAP02 conserva
recetas y equipo viajero; no sustituye la salida narrativa, cuya limpieza de
objetos físicos sigue vigente.

Los guardados antiguos se crearon con fuentes auténticas 0ab, luego se
superpuso 0ac en la misma ruta. Se conservaron los 130 conocimientos anteriores,
etapas, lecciones, El Loco y la identidad de la primera arma. La receta 130 se
incorporó tanto en MAP01 como en MAP02. La tarea antigua siguió siendo de
flechas, con reservas y tiempo intactos: aun seleccionando virotes después de
cargar, produjo diez flechas una sola vez. Repetir la enseñanza no duplica nada.

Las escenas privadas preparan etapas, materiales y equipo; adelantan el tiempo
de fabricación mediante el helper diagnóstico existente. Verifican el proceso
nativo y su persistencia, no el recorrido completo ni la espera a tiempo real
del autor. Revisión visual a 1280×720: guía de Ronnie y receta de virotes con
su icono, árbol y estaciones legibles. Validador aprobado: cinco documentos,
74 audios, doce modelos de estaciones y 24 textos españoles de Caella.

Mapas y recursos audiovisuales conservan los bytes de 0ab. El delta pasa CRC
y reconstrucción exacta sobre esa base: quince archivos modificados más
PRUEBAS_4_33_0ac.txt, sin ejecutores, escenas privadas ni PK3. El autor
confirmó que todas las pruebas de 0ac dieron correcto.

## Validación de 4.33.0ab — aprobada por el autor

109 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
33 en español, 33 en inglés, 15 al recargar durante la inmersión, 11 durante
la devolución y 8 después de completarla; 9 al actualizar un guardado auténtico
0aa, hacer la práctica, subir la escalera y viajar a MAP02. Las cifras de
recarga cuentan sólo comprobaciones ejecutadas después de cargar, sin sumar
otra vez el contador que guardó la escena.

Se abrió Ronnie con Usar y se recorrieron las páginas USDF reales. Lectura y
rechazo no inician; confirmar registra; Detalle y diálogo usan el resultado.
La piscina real acreditó WaterLevel 3 y gasto nativo. Mojarse sin cubrir la
cabeza, ejecutar el helper diagnóstico en seco, exenciones sin gasto y llenar
Aire por depuración no completaron. Menos de un segundo queda pendiente;
la devolución parcial tampoco completa. No se confundió con recuperación de
Aire al correr. Reabrir conserva la práctica y el viaje conserva las lecciones.

Guardado antiguo creado con fuentes 0aa antes de superponer el delta en la
misma ruta: tres bools nuevos falsos, etapas, equipo, lecciones y 78 cartas
conservados. Se aceptó la práctica, se registró inmersión y se subieron los
escalones mediante movimiento con colisiones nativas hasta x2190/z8, WaterLevel
0, sin perder salud. La recuperación completó la práctica. Las escenas privadas
preparan etapas, atributos y equipo para cubrir casos; no añaden contenido ni
sustituyen el recorrido manual del autor con su personaje.

Revisión visual a 1280×720: las siete opciones de Ronnie y las instrucciones de
la piscina se leen completas. Textos de diálogo y Detalle comprobados en ambos
idiomas. Validador aprobado: cinco documentos, 74 audios, doce modelos de
estaciones y 24 textos españoles de Caella. Los tres WAD y todos los recursos
audiovisuales conservan los bytes de 0aa. La revisión de código confirma que
los observadores no modifican costes, regeneración o requisitos de misión.
El delta pasa CRC y reconstrucción exacta sobre 0aa: trece archivos modificados
y PRUEBAS_4_33_0ab.txt, sin ejecutores, escenas privadas ni PK3.
El autor confirmó que todas las pruebas de 0ab dieron correcto.

## Validación de 4.33.0aa — aprobada por el autor

1271 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
1259 de reglas/acciones, 10 al actualizar un guardado real de 0z y viajar,
y 2 al recargar el guardado resultante de 0aa y volver a viajar.

Cobertura: las 78 cartas individualmente sobre los doce atributos, colección
completa, base antes de porcentaje, decimales, recálculo sin acumulación y
snapshots del Diario. Divisores con atributo 0, 0,3, 1, 10, 25, 50, 100 y 150;
daño real de jugador/NPC y conservación de la curva de Dolor/Lucidez. Se
compararon colisiones nativas con su expresión sustractiva; además, los cuerpos
de ReceiveCaelumImpact en jugador y NPC son idénticos a 0z.

Barrido: cuatro direcciones, daño igual al primario bajo condiciones de crítico
y precisión controladas, coste único triple, recuperación, Aire insuficiente,
obstáculos sólidos y piso 3D, aliados y alcance. Se ejecutaron los estados Zoom
de los selectores nativos de las tres armas y guanteletes; mantener el botón
no repite. Barrido cargado consume la carga y cuesta seis primarios sin carga.
Magia: gastos reales de los cuatro implementos, T1/T2/T3, normal/cargado y
rechazo por Ánima insuficiente a Elocuencia 100. Se conservan las bases propias.

El guardado 0z se generó con sus fuentes auténticas antes de superponer el delta.
Conservó cartas/equipo/etapa/lecciones y reconstruyó atributos y un hechizo
cargado pendiente que antes costaba cero. Se guardó con 0aa, recargó y verificó
viaje real a MAP02 sin duplicar bases ni perder el arma. Las escenas preparan
cartas y equipo para estos ensayos: no añaden contenido al juego entregado.
Revisión visual del Diario a 1280×720: colección completa y un Menor sin El Loco,
con la tabla de base y porcentaje separada. La adquisición restante de cartas
continúa planificada, no se declara terminada.

Validador del proyecto aprobado: cinco documentos, 74 definiciones de audio,
12 modelos de estaciones y 24 textos españoles de Caella. Los tres mapas y
todos los recursos audiovisuales mantienen los bytes de 0z. El ZIP pasa CRC
y reconstrucción exacta del delta sobre esa base; incluye sólo 16 archivos
modificados y PRUEBAS_4_33_0aa.txt. No contiene ejecutores, mapas privados o PK3.
El autor confirmó que todas las pruebas de 0aa dieron correcto.

## Validación de 4.33.0z

75 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
25 en español, 25 en inglés, 13 al cargar la práctica pendiente, 5 al cargarla
completa y 7 al actualizar un guardado real generado con fuentes 0y.
Se abrió Ronnie con Usar, se recorrió el diálogo y se ejecutaron las acciones
nativas de Inventario D/C sobre objetos reales. Se verificaron rechazo de
material reservado y Caja no poseída, exclusión de consumo y primera arma,
reducción efectiva de masa, persistencia y transición real a MAP02. Las escenas
preparan etapa y sobrantes para comprobar estas rutas; no sustituyen el recorrido
del autor. Captura de valores de carga revisada a 1280×720.
Validador aprobado; los tres WAD y recursos audiovisuales conservan sus bytes
de 0y. El ZIP pasa CRC y reconstrucción exacta del delta sobre esa base.
0z quedó integrado en la base completa 0aa cuya prueba el autor aprobó.

## Validación de 4.33.0y — aprobada por el autor

80 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 Linux/Freedoom:
27 en español, 27 en inglés, 15 al cargar progreso parcial, 4 al cargar la
práctica completa y 7 al cargar un guardado real generado con fuentes 0x.
Se abrió al Ronnie original con Usar y se recorrió el diálogo nativo. Los
escenarios inyectan condiciones de movimiento y llaman a las funciones reales
de gasto/recuperación en ciclos acelerados: comprueban contabilización, no el
ritmo de una caminata manual. Se verificaron exclusión de bebida energética,
movimiento nulo y reservas vacías; costes de recuperación; guardados parciales
y completos; viaje real a MAP02 y conservación de la primera arma.
Captura en español revisada a 1280×720. Los tres WAD y los recursos audiovisuales
son idénticos a 0x. Validador aprobado; CRC y reconstrucción del delta verificados.
El autor aprobó controles y recorrido manual en Windows de 0y. No se declara probado un nuevo mapa ni una ruta de obstáculos.

## Validación de 4.33.0x — aprobada por el autor

108 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2 nativo Linux/Freedoom:
32 en español, 32 en inglés, 17 desde guardado parcial, 4 desde guardado completo,
15 de capacidad/reintentos/estados bajos/refresco de los cinco consumibles y 8
al cargar un guardado real generado con fuentes 0w. Se utilizó Inventario nativo
para consumir; se esperaron los diez segundos reales de pulsos. El cruce a MAP02
fue nativo y conservó progreso y primera arma. Captura del diálogo revisada a
1280×720. Escenarios aislados preparan etapas, carga y reservas para ejercitar
estas condiciones; no sustituyen las pruebas del autor en Windows.

El validador pasa. Los tres WAD y todos los recursos audiovisuales son idénticos
a la base aprobada. El ZIP se comprueba por CRC y por reconstrucción exacta de
archivos modificados sobre 0w. Todas las pruebas de 0x fueron aprobadas por el autor.

## Validación de 4.33.0w — aprobada por el autor

Escenarios enfocados en GZDoom 4.14.2 nativo, Linux/Freedoom. Se preparan etapa,
primera arma con desgaste y componentes; los objetos/tareas de producción son
los reales. Sólo se adelanta el tiempo mediante la función de depuración para
no esperar el ciclo completo. No se declara medido el ritmo de juego en Windows.

- Usar abre al Ronnie original. La pregunta opcional, pasos, pausas y respuesta
  posterior se comprueban en español e inglés. Detalle reconoce la finalización.
- Selección y desequipado mediante Inventario nativo; persiste la selección en
  Oficios. La red real del segundo piso abre con Usar y reserva materiales.
- Iniciar, cancelar y pausar no acreditan la práctica. Cancelar libera reservas
  sin consumir materiales; cerrar detiene el contador de la misma tarea.
- Terminar la reparación consume materiales y restaura el mismo ItemId, sin
  objetos, recetas o cambios de etapa añadidos como recompensa.
- Guardados reales con tarea pausada y práctica terminada; continuar desde ellos
  y cruzar conserva el registro y la primera arma. Compatibilidad desde 0v.
- Auditoría de cuatro conjuntos de armadura y cinco sellos T1, talle M, con
  25/50/100% en todas las capas. Capacidades de vetas leídas del mapa en el motor.
  Estos cálculos no simulan tiempo de extracción, mermas previas ni stock usado.

Resultados: 83 comprobaciones aprobadas, cero fallos: 27 en español, 27 en
inglés, 11 al cargar la tarea pausada, 5 al cargar la práctica completada y 13
de compatibilidad desde un guardado 0v. Captura del diálogo en español revisada
a 1280×720. Validador del proyecto aprobado; nueve claves nuevas en ambos
idiomas. Los tres mapas y los recursos audiovisuales conservan sus bytes de 0v.
El paquete se verifica por CRC y por reconstrucción del acumulativo sobre 0u.
El autor confirmó la descarga, aplicación y aprobación de todos los cambios de 0w.

## Validación de 4.33.0v — aprobada dentro del acumulativo 0w

GZDoom 4.14.2 nativo, Linux, Freedoom 0.13, con escenarios aislados que preparan
las etapas e inventarios. Se verifica el viaje real; no se simula cambiando el
nombre del mapa ni se afirma haber repetido el tutorial completo.

- Confirmación y cancelación mediante Usar/USDF nativos; fabricación pendiente,
  distancia/altura, propiedad, ausencia de limpieza antes de completar el fundido.
- ChangeLevel real: misión completada, misma Caja/ItemId/Owner, arma guardada con
  su condición, eliminación de extras personales y almacenados, Tarot y recetas.
  Sin escudo/capas fantasma ni reposición completa de recursos. Recuperación y
  equipamiento del arma desde el inventario nativo después de llegar.
- Guardado real durante el fundido y carga para continuar el mismo traslado;
  guardado tras equipar en alcantarillas y carga sin repetir la Voz.
- Guardado generado con fuente 0u y cargado sobre la misma ruta con 0v. La
  comprobación detectó incompatibilidad al modificar TEXTMAP; se conservó
  MAP01.wad exacto y se pasó la modificación al controlador. La versión final
  debe conservar ese hash para admitir partidas existentes.
- Presentación y localización español/inglés; capturas nativas de puerta y
  alcantarillas. TEXTMAP diagnóstico preservado y referencias movidas a CADEV02.

Resultados finales: 89 comprobaciones aprobadas, cero fallos: recorrido nativo
38, reanudar fundido 22, cargar llegada 2, migración 0u -> 0v 12 y salvaguardas
15. El contador serializado de una partida incluye las comprobaciones previas;
no se cuentan de nuevo al cargar. El save de origen se creó con fuente 0u real.
Las salvaguardas cubren también pieza caída, pieza destruida sin reparación
regalada, cuatro familias mágicas, requisito de Caja/carta/Rulo e interrupción.

CADEV02 abrió en GZDoom con IA masiva desactivada para comprobar el cambio de
nombre; no se repitió la prueba de rendimiento de multitudes. El validador pasó:
cinco documentos, 74 audios, 12 modelos de estaciones y referencias conservadas.
Las 17 claves del retorno están presentes una vez en cada idioma. MAP01.wad
mantiene SHA-256 c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.
Corrección de registro: el autor confirmó que su última versión recibida fue 0u.
Luego se entregó el acumulativo y el autor aprobó todos sus cambios, incluidos 0v y 0w.

## Validación de 4.33.0u — aprobada por el autor

- GZDoom 4.14.2 nativo, Linux, Freedoom 0.13: 42 comprobaciones de equipo,
  cero fallos. Préstamo sin escudo; reparación de modelo obsoleto; escudo real,
  bloqueo, desequipado, referencia perdida, mandoble, regreso a espada,
  almacenamiento, rotura, reparación, retirada y capas residuales; guanteletes
  gigantes conservan su defensa propia. Se mantienen las identidades reales.
- Esquiva y UI: 13 comprobaciones en español y 13 en inglés, cero fallos.
  Entrada nativa de movimiento lateral, Zoom y giro. Moverse en otra sala
  o piso y girar la cámara no conceden la marca. Caminar de costado 48 MU
  en la sala sí la concede y actualiza el Diario. Usar abre al Rulo original;
  inicio, repaso y equivalencias muestran la indicación del mandoble.
- Un save creado realmente con fuente 0t y estado de escudo obsoleto se carga
  con 0u sobre la misma ruta: 9 comprobaciones, cero fallos. Desaparecen capas
  y bloqueo fantasma; conserva préstamo, Owner, ItemId y etapa de la misión.
  El registro viajero almacena el estado reparado sin crear otro objeto.
- Reproducción acotada: en partida limpia 0t el préstamo no daba un escudo.
  El síntoma se reprodujo preparando el estado incoherente en el motor; no
  se recibió el guardado concreto del autor. La corrección cubre también capas
  residuales sin estado lógico activo.
- Revisión visual del Diario y compilación sin errores del código entregado.
  Versión y cinco documentos sincronizados, traducciones de ambos idiomas,
  recursos existentes y CRC del ZIP comprobados. MAP01.wad no cambia.

Son escenarios enfocados que preparan inventario y etapas; no se repite todo
el tutorial ya aceptado. El autor confirmó exitosas todas las comprobaciones
de 0u; la ampliación de salida se implementa en 0v.

## Validación de 4.33.0t — resto aprobado por el autor

- GZDoom 4.14.2, ejecución nativa en Linux con Freedoom 0.13 como IWAD de
  prueba: 65 comprobaciones del flujo y las conversaciones, cero fallos.
  Usar abre el USDF real; cerrar deja la esencia, una captura interrumpida
  permite reintentar, la completa otorga una carta y cambia 80 -> 90.
- Las doce cifras conservan exactamente base ×1,02. Cinco recálculos seguidos
  no acumulan el factor, no se regala salud, y la Caja conserva Owner/ItemId.
  Dos Mayores más un Menor dan 5%; las 78 cartas dan 100%, no interés compuesto.
  Estas últimas combinaciones son pruebas del registro, no contenido obtenido
  durante el tutorial. Tras comprobarlas se restaura sólo El Loco.
- Guardar durante la animación y cargar reanuda la captura: 24 comprobaciones
  posteriores aprobadas. Un guardado ya completado conserva colección, etapa,
  Caja y atributos; la inspección visual parte de ese guardado.
- Migración real desde fuente 0s hacia 0t en la misma ruta: 14 comprobaciones
  aprobadas. La Caja, 500 unidades de material almacenado, masa total y primera
  arma (ItemId 2) se conservan. Los atributos enteros de 0s cargan como double
  sin pérdida. Aparece la esencia y puede capturarse sin empezar partida nueva.
- Los cinco actores originales abren sus conversaciones posteriores mediante
  Usar nativo. Se recorren también las preguntas de Palomo sobre colección y
  almacenamiento; las páginas muestran sus textos localizados correctos.
- Inspección de la aparición en la cueva y del Diario en español a 1280×720
  y en inglés a 1024×768. La carta conserva proporciones en 16:9 y 4:3.
  Personaje muestra decimales; Misiones y F/Detalle reflejan la captura.
- Validador: versión/README y cinco docs sincronizados; 74 audios, 12 modelos
  de estaciones, claves de Caella conservadas y 25 claves nuevas en ambos
  idiomas. MAP01.wad idéntico a 0s, SHA256:
  c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

Los escenarios preparan etapas y condiciones ya aprobadas, y sitúan a Palomo
en su destino para comprobar la conversación. No reemplazan una partida
completa ni la escucha en Windows del autor. El autor aprobó las demás pruebas
de 0t; el escudo fantasma y la guía de defensa se atendieron en 0u. La salida y
poderes activos no se prueban como funciones implementadas.

## Validación de 4.33.0s — aprobada por el autor

- 130 comprobaciones aprobadas, cero fallos, en GZDoom 4.14.2: 61 del
  diálogo/recompensa/almacenamiento, 17 al recargar un guardado 0s y 26 por
  cada variante de guardado 0r (sin Caja y con propiedad anterior).
- Usar y USDF nativos recorren las trece páginas nuevas: visita temprana,
  preguntas opcionales, volver atrás, cerrar antes de aceptar, aceptar y
  reabrir después. Cada requisito de misión ausente rechaza la recompensa;
  también se rechaza abrir desde otro piso o fuera de alcance.
- La aceptación avanza 75 a 80, concede una sola instancia con Owner/ItemId
  y suma 10 kg una vez. La acción repetida conserva identidad, etapa y peso.
  El almacenamiento y retiro de una pila personal de 5 kg conserva cantidad,
  slots y reducción de peso. La Caja no consume un slot de su contenido.
- Se crean guardados nativos con fuente 0r y se cargan con fuente 0s en la
  misma ruta. Se preservan el Palomo original, la primera arma (ItemId 1),
  su contenido y la etapa. La Caja recibe ItemId 2 una sola vez. En la
  variante ya propietaria, cargar y aceptar conservan la carga de 12,2 kg;
  en la variante sin Caja, la entrega cambia de 6,2 a 16,2 kg.
- Recargar el guardado 0s conserva Caja, contenido, propietario y fase 80;
  Palomo abre la ayuda posterior a la entrega. Captura y salida siguen sin
  premiarse y la misión permanece activa.
- El validador del proyecto pasa: versión/README, cinco docs, 74 archivos de
  audio, 12 modelos de estación y 24 claves de Caella en español. Las 27
  claves nuevas tienen versiones en español e inglés. MAP01.wad conserva
  SHA256 c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

Los escenarios preparan las etapas y sitúan la instancia original de Palomo
en su destino, con la ruta terminada. Usar, las páginas USDF, almacenamiento
y guardados sí se ejecutan en el motor. No se repite el recorrido de escaleras
ya aceptado ni una partida completa. El autor confirmó después que todas
las pruebas de 0s fueron correctas y autorizó continuar con 0t.

## Validación de 4.33.0r — aprobada por el autor

- GZDoom 4.14.2 reproduce el bloqueo de 0q: Argento y Caella conservan toda
  su salud, pero INCOMBAT=1 hace fallar StartConversation. Rulo/Ronnie responden.
- 57 comprobaciones de protección/recuperación/USDF: daño letal normal y
  forzado para los cuatro, 1 de vida, cero eventos de muerte, reparación de
  cuerpo/altura sin alterar totales, ocho aperturas con Usar real y cierre
  de Rulo desde el menú nativo hasta fase 75.
- 32 comprobaciones al cargar un guardado nativo 0q en la misma ruta de juego:
  Argento bloqueado por combate y Caella como cadáver real (salud -898840,
  CORPSE/KILLED). Ambos se reparan; permanecen cuatro instancias, con altura
  correcta, protección, ocho aperturas/cierres de diálogo y fase 75 conservada.
- 32 comprobaciones al cargar el guardado 0r posterior al cierre: protección,
  salud, cuatro residentes, etapa 75 y apertura/reapertura de sus diálogos.
- El validador del proyecto pasa: README/versión, cinco docs, 74 archivos de
  audio, 12 modelos de estación y 24 claves de Caella en español. El delta
  cambia sólo LANGUAGE, CaelumAnchoredResident y documentación. MAP01.wad
  mantiene SHA256 c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

Son escenarios controlados con precondiciones de misión y daño preparado;
Usar, USDF y guardados sí pasan por el motor. No sustituyen la partida del
usuario ni una inspección visual del encuentro. El autor confirmó correctas
todas las pruebas de 0r y pidió proseguir con el siguiente bloque.
Un actor ya destruido no puede repararse a partir de una instancia inexistente;
los residentes base dejan cuerpos persistentes y la variante probada se recupera.

## Validación de 4.33.0q — resto aprobado por el autor

- 146 comprobaciones aprobadas en GZDoom 4.14.2: 36 de la rama/reintento,
  37 del grupo, 7 de USDF/Usar y 66 de migración/guardados.
- Los cuatro infligen daño nativo al Toro; éste ataca compañeros y puede
  dejarlos agachados. El reintento restaura los cuatro y una baja causada por
  un compañero acredita victoria al jugador. Fuego amigo rechazado.
- Usar real: orientación de Argento en primera persona, entrega de llave y
  devolución a Rulo dentro del recinto. Capturas inspeccionadas en español.
- Guardado nativo 0p en combate: conserva daño del Toro, prácticas, munición
  propia/prestada, ItemId, consumo del cajón y 38 estaciones; incorpora el grupo.
- Guardado 0q: conserva un aliado caído y las referencias del grupo; permite
  reintentar, vencer, cerrar y volver a cargar con 12.500 unidades de cuero.
- Guardado 0p completado: conserva su cuero anterior y las cuatro instancias
  en casa. También se ensaya la precondición de victoria pendiente sin Toro.
- Las pruebas usan una copia privada, precondiciones de misión preparadas y
  daño/temporizadores controlados para los límites; el ensayo de participación
  deja actuar a la IA y registra impactos reales. No sustituye el balance del
  autor ni afirma haber completado una partida normal de principio a fin.

Guardados anteriores ya completados conservan el botín que habían producido:
la nueva cantidad se aplica a victorias todavía pendientes, sin retirar cuero
propio ni rellenar el cajón. El WAD mantiene la misma huella de 0p.
El autor aprobó las demás pruebas de 0q. La apertura poscombate con Argento y
Caella no estaba cubierta: 0r reproduce y corrige esa omisión.

## Validación de 4.33.0p — resto aprobado por el autor

- GZDoom 4.14.2: carga completa, 36 comprobaciones de la rama/recinto/reintento;
  116 comprobaciones con las 36 opciones iniciales y acciones nativas.
  La reposición de munición se comprueba sin gastar la reserva propia ni curar.
- Uso/USDF reales: inicio de Rulo, páginas de prácticas, llave de Argento y
  devolución final. Detalle se verifica con F y capturas del motor.
- Guardado nativo de 0n: conserva etapa, fabricación pausada, gasto del cajón y
  38 estaciones. Sobre esa partida se prueba el enlace a la nueva rama.
- Guardado en combate: conserva daño del Toro, seis prácticas, propietario del
  encuentro, ItemId y munición gastada. Derrota y reinicio funcionan tras cargar.
- Guardado en fase 75: conserva sólo la munición propia, arma inicial y una
  única cantidad de cuero. El Toro disipado no reaparece.
- El WAD conserva SHA-256
  `c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c`.
  No se redistribuyen motor, IWAD, PK3, guardados ni fixtures de ensayo.

Los ensayos preparan precondiciones y aceleran temporizadores en copias privadas;
validan transiciones y acciones del motor, no sustituyen la partida del autor.
El autor confirmó el resto de sus pruebas; las tres observaciones se atienden
en 0q. Ese bloque dejaba el epílogo pendiente; 0s–0v incorporan su cierre.
La auditoría final del tutorial continúa en el roadmap.

## Validación de 4.33.0o

- GZDoom 4.14.2 compila y carga MAP01 nuevo y un guardado real de 0n sin
  errores de scripts ni de carga. No se repite la matriz de juego ya aprobada.
- El WAD contiene un único manual tipo 18106, en (-364,800,0); el guardado
  conserva ese mismo origen. El retiro apunta sólo a ese ejemplar del mundo,
  con un marcador independiente para migrar guardados ya preparados por 0n.
- WAD y demás archivos de runtime conservan su contenido; sólo cambia el
  controlador de MAP01. README y los cinco documentos quedan en versión 0o.
  ZIP cotejado contra 0n: siete archivos modificados y un TXT de pruebas.

Comprobación solicitada en 0o: desaparición del manual exterior y conservación
de recetas. El autor continuó con Rulo y aprobó después las demás pruebas de
la base; las observaciones de 0u ya fueron aprobadas por el autor.

## Validación de 4.33.0n — aceptada el 2026-09-11

- Runtime completo en GZDoom 4.14.2: carga sin errores. 281 comprobaciones
  de las 38 estaciones, colisión/altura, puertas, cajón único y cinco vetas.
- 48 comprobaciones de cantidades por talle, retiro/devolución y migración
  de cuero, recetas/fabricación/cancelación de flechas, consumo real de materias
  primas, primera arma, custodia/transferencia de llave y botín único del Toro.
- Entrada nativa: 11 comprobaciones. Tab cierra Oficios sin estación y con
  ella; G filtra; Usar abre banco/cajón/Argento y las respuestas cambian inventario.
  Capturas revisadas de cajón, receta de flechas, llave y fila de estaciones.
- Palomo recorre ambos tramos de escalera con movimiento y colisión reales,
  llega a (500,120,264) visible/sólido y sin teletransporte. La ruta tardó unos
  21 segundos en el ensayo sin obstrucciones; el jugador puede bloquearlo.
- Tres recorridos de guardado/carga, 138 comprobaciones: cargar 0m conservando
  Caella y residentes; guardar una tarea de flechas pausada y a Palomo en marcha;
  reanudar y completar ambos; transferir llave, derrotar Toro, guardar/cargar
  de nuevo. Recetas 128/129, munición, stock gastado, llave y botín persisten.
  No se duplica el Toro ni se devuelve la llave al custodio.
- Todos los ensayos anteriores terminaron sin fallos. Las pruebas de recetas
  inyectan materias primas y adelantan el reloj de fabricación; las de la llave
  preparan las banderas futuras de Rulo. No acreditan ese capítulo jugable.
- README y cinco documentos coherentes con 0n. WAD, 74 archivos de audio,
  doce modelos de estación y arte sin cambios. Delta exacto sobre 0m; un TXT
  adicional con aplicación/pruebas. No se incluyen herramientas de ensayo.

El autor confirmó exitosas todas las pruebas de 0n. La aceptación cubre el
alcance implementado; no convierte en jugables las ramas todavía pendientes.
Los ensayos aislados usan GZDoom 4.14.2/OpenGL con instrumentación privada.
No acreditan duración de una partida ni cooperativo. Motor, IWAD, fixtures,
capturas y guardados quedan fuera del parche; validación de 0m en HISTORY.md.

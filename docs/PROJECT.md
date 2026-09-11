# Caelum Argenteum — Proyecto, estado y roadmap

Versión documental: 4.33.0s — 2026-09-11.

## Estado actual: 4.33.0s

**Base:** carpeta completa 0r. El autor confirmó correctas todas sus pruebas.
Se implementa el siguiente bloque acordado: Palomo final y Caja, fase 75 a 80.
Palomo usa la misma instancia que ya llegó arriba por las escaleras. No se
cambia la ruta, la visibilidad, las estaciones ni la supervivencia aceptada.

Tras cerrar Argento, Caella, Ronnie y Rulo, hablar con Palomo en el segundo
piso abre su diálogo final. Conserva las metáforas y las preguntas opcionales
de MAP01.txt. Sólo aceptar explícitamente concede la Caja y cambia de etapa.
Salir antes permite retomarlo. Volver después ofrece ayuda de almacenamiento
y la ruta hacia la cueva. Una visita temprana orienta según la etapa actual.

La Caja tiene un Inventory nativo único, propietario e ItemId persistente,
con el almacenamiento existente. Sus 10 kg se cuentan una sola vez. Los
personajes que ya la poseían conservan contenido/peso al migrar; la entrega
narrativa sigue pendiente hasta aceptar la conversación. La repetición no
duplica objetos ni identidad. Los objetos equipados, prestados o reservados
mantienen las restricciones anteriores. El arma inicial conserva su ItemId.

El Diario y Detalle registran la adquisición y el uso de C en Inventario.
Argento toma esa etapa actual. Palomo aparece como ubicado arriba desde la
fase 75. La Caja no inicia comercio ni resuelve automáticamente El Loco.

**Límite de 0s:** fase 80. El Loco se manifestará en la cueva bajo la mansión,
accesible por el pasaje descubierto con Caella y el ascensor. Palomo da esa
ruta; la aparición/captura, recompensa de Tarot y salida son el próximo bloque.
No buscar una esencia capturable en 0s ni declarar terminado MAP01.

Se conservan el grupo con Buddha de 0r, los diálogos de liderazgo/fuerza innata,
los 12,5 kg de cuero y el cajón de guanteletes. La cobertura T1 completa y la
auditoría final del tutorial siguen pendientes, sin agregar bloqueos nuevos.

La base 0n aprobada incluye:

- Las 38 estaciones conservan sus instancias: esquinas en dormitorios y una
  fila de doce contra la pared del fondo del segundo piso. Puertas y estaciones
  rechazan activaciones desde otro nivel o sin línea de visión.
- Tab cierra Oficios, también durante una tarea; G filtra. Cerrar pausa la tarea.
- Arco y arco largo enseñan diez flechas por lote y sus componentes, usando
  crafting e inventario nativos. No consumen el lugar de la primera arma.
- Cinco vetas de gemas al fondo de la cueva. El cajón queda sólo con cuero de
  vaca para guanteletes gigantes al 25 % por capa y al talle del personaje:
  96 kg en M. La corrección final del autor limita el abastecimiento a T1.
- Toro colocado tras la puerta de plata y Argento como custodio de la llave.
  La entrega exige las preparaciones con los cuatro: las prácticas de Rulo
  preceden al Toro. El presupuesto de cuero por recetas de 0n queda sustituido
  por el rendimiento basado en masa de 0q.
- Palomo corre visible por quince puntos, abre las puertas libres necesarias
  y sube por ambas escaleras hasta la habitación del segundo piso. No se
  teletransporta ni desaparece; continúa desde su punto al cargar.
- Indicación compartida neutral sobre la pared marcada y diálogos de recursos
  actualizados. Se conserva la devolución del bastón ante Caella de 0m.

Las lecciones adicionales de supervivencia de Ronnie siguen planificadas
como ampliación del tutorial; no bloquean retroactivamente las ramas aceptadas.

Se conservan WAD, audio, modelos, jardín y poses aceptados. Las estaciones
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


## Roadmap inmediato: terminar MAP01

Cada bloque termina con pruebas enfocadas y aceptación del autor antes de
ampliar el siguiente. La numeración de las correcciones intermedias depende
de lo que arrojen esas pruebas; no son plazos de entrega.

| Orden | Bloque | Alcance restante / criterio de cierre |
| --- | --- | --- |
| 0 | Base hasta 4.33.0n | Todas las pruebas aprobadas por el autor el 2026-09-11. Se conserva la migración 0h. |
| 1 | 4.33.0o: retiro del manual exterior | Entregado; el autor pidió proseguir con Rulo. Mantener la limpieza y las recetas aprendidas. |
| 2 | 4.33.0p–0r: Rulo/Toro | Resto de 0q aprobado. 0r corrige el diálogo poscombate y protege a los residentes; expresa liderazgo y fuerza innata. Todas las pruebas de 0r aprobadas por el autor. |
| 3 | 4.33.0s: Palomo final, fase 80 | Diálogo final y Caja única implementados sobre la misma instancia. Pendiente aceptación del autor. |
| 4 | **Siguiente bloque: El Loco en la cueva y salida, fases 90–100** | Manifestación en la cueva bajo la mansión tras recibir la Caja; indicaciones de acceso en diálogo/Detalle. Captura/recompensa única, transferir el arma elegida por ItemId, completar misión y transición narrativa. La limpieza técnica de temporales de 0l no implementa por sí sola esta salida. |
| 5 | Auditoría final del tutorial | Recorrido completo, balance acompañado, cobertura T1 con botín realista y guardados. Ampliaciones previstas de Ronnie: reparación, alimento/agua y paso de agua; cartuchos/virotes. No bloquear retroactivamente las ramas aceptadas. |
| 6 | Alcantarillas de MAP02 | Construir el mapa narrativo; el MAP02 actual continúa como campo de diagnóstico de actores. |

La verdad autoral y las revelaciones futuras no deben filtrarse a los NPC del
inicio. MAP01.txt contiene la especificación completa y las correcciones que
prevalecen sobre su primera versión.

## Roadmap general por versiones

Esta es la secuencia ya planificada, reconciliada con lo implementado. Los
registros originales siguen completos en HISTORY.md. “Base implementada”
no significa que todo el contenido de ese sistema esté terminado.

| Hito | Estado y trabajo pendiente |
| --- | --- |
| V4.27: controles de combate | Rutas nativas implementadas: Fire/AltFire, Reload contextual, Zoom Block/ADS y User1–4. Completar/registrar la matriz pendiente por familia cuando corresponda; conservar lo aceptado. |
| V4.28: Channel de Sellos | Efectos actuales sin clima aceptados en 0bp. Extensiones dependientes de clima pasan a V5; no reabrir los efectos cerrados. |
| V4.29–V4.31: crafting y ciclo de equipo | Base de recetas, reservas, lotes, eficiencias independientes, reparación y desarme aceptada. Quedan distribución narrativa de conocimiento, recompensas/hojas/tiendas/descubrimientos y bonos de eficiencia todavía sin valores autorizados. |
| V4.31: recursos, botín y contenedores | Fuentes físicas y alijos tienen base; completar tablas de botín por planta/animal/monstruo, contenido/capacidad/propiedad/robo/reposición de contenedores y adquisición sistemática de materiales. La expansión persistente de biomas va en V5. |
| V4.32: NPC, comercio y primera persona | Use/USDF, transacciones, monedas y Caja aceptados. Falta comerciante canónico posterior y contenido de tiendas. Extender la vista modular de espada/manos/escudo 0o a las demás armas con arte propio. |
| V4.33: misiones, reputación y facciones | Registro por personaje aceptado; terminar MAP01, desarrollar misiones secundarias/cadenas y consecuencias jugables de pertenencia/reputación. Los cuatro dominios técnicos actuales no equivalen a las ocho facciones narrativas completas. |
| V4.34: arquitectura del mundo y viajes | Reutilizar módulos de habitación/escalera ya validados; puertas cerradas/con llave y pisos adicionales. Definir ubicaciones, conexiones, caravanas y puntos de integración de viajes/eventos. No confundir arquitectura de mapas con refactor de código. |
| V4.35: calendario, clima y eventos | Calendario/estaciones, duración del día, clima local y planificación de eventos/viajes. Después del reloj global, descanso y avance del tiempo con sus interrupciones; sillas/camas pueden reutilizar interacción, inmovilidad y cámara de seguimiento. Publicar un estado ambiental común de temperatura, viento, precipitación y humedad. El modelo térmico del personaje llega después. |
| V4.36: entorno móvil y peligros físicos | Rocas que ruedan, objetos que caen y superficies peligrosas; luego avalanchas, arietes, catapultas y sectores móviles mediante el núcleo físico. Extraer Impact Physics como paquete independiente sólo tras cerrar su validación en Caelum. |
| V4.37: Tarot y Trucazo | Activación de cartas poseídas/seleccionadas con User3, costes/cooldowns/persistencia y progresión; después contenido de cartas y minijuego Trucazo sobre inventario/NPC/eventos estables. |
| **V5.0: arquitectura modular del código** | Primer bloque de V5, después de cerrar los bloques V4 pendientes. Separar responsabilidades, reducir CaelumPlayer a coordinación y migrar mediante adaptadores pequeños. Una implementación de inventario/jugador/Tarot; autoridad multijugador transversal. Preservar guardados, entradas y selectores. |
| V5.1: exposición térmica | Modelo de calor/frío basado en clima, zonas, actividad, humedad persistente, viento y equipo real; Resiliencia, consumibles, refugios, secado, descanso y aclimatación. Curvas numéricas pendientes de balance autoral. |
| V5.x: recursos y biomas marinos | Fuentes 3D persistentes, extracción cuerpo a cuerpo cortante/perforante, dureza/rareza/profundidad/región/habilidad, agotamiento y regeneración. Biomas marinos, algas/yodo y aguas no potables; tiendas mantienen acceso a materiales remotos. |

### Todo el alcance transversal pendiente

Estos compromisos no desaparecen por carecer de un número de parche. Su
implementación se ubica cuando estén disponibles sus dependencias.

| Área | Alcance planificado y límites actuales |
| --- | --- |
| Campaña y mundo | Objetivo de 78 cartas (22 Mayores y 56 Menores) y al menos 78 mapas; geografía inspirada en Argentina, costas/Antártida/mar profundo, ciudades aéreas y regiones sobrenaturales. Capítulos, encuentros, desenlaces políticos y revelaciones según canon. La primera entrega sigue concentrada en MAP01. |
| Misiones | Principales/secundarias, requisitos, objetivos, cadenas/dependencias, fracaso y abandono; recompensas de objetos/dinero/reputación/desbloqueos. El registro actual tiene 32 slots, ocho objetivos y cuatro estados; abandono y contenido amplio requieren ampliación. Mayores para principales, Menores para secundarias; encargos/eventos/rumores/contratos no son automáticamente otra carta. No introducir XP por combatir: la progresión canónica depende del Tarot. |
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
| Habilidades | Efectos concretos de User1 racial y User4 clase, definidos raza por raza y clase por clase. User2 conserva Sellos; User3 conserva Tarot. No inventar poderes ni valores para llenar los hooks existentes. |
| Tarot | Colección, posesión, selección, activación, bonificaciones y despertar de armas de esencia; cartas con efectos de exploración, respiración y Caja según diseño. Completar las 78, sus misiones y persistencia; no confundir un hook con poderes terminados. |
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
| maps | 2 | MAP01 y campo de pruebas MAP02; hashes invariantes. |
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

Con GZDoom cerrado, copiar src, docs y README.md del parche sobre la carpeta
completa 0r y aceptar reemplazos. Combinar carpetas; no sustituir src por una
carpeta que contiene sólo el delta. Iniciar run_dev.bat para reconstruir y jugar.
El ZIP sólo contiene archivos nuevos/modificados y PRUEBAS_4_33_0s.txt.

Se conservan build_dev.ps1 y run_dev.bat existentes: construyen el juego, no
instalan parches. Se mantiene la migración 0h aceptada y las rutas del motor/IWAD
del autor. No se entregan ni ejecutan más aplicadores por versión. El TXT de
pruebas queda junto al ZIP; sus resultados se integran en estos cinco documentos.

## Validación de 4.33.0s

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
ya aceptado ni una partida completa; la inspección visual y la aceptación
del autor de 0s quedan pendientes en PRUEBAS_4_33_0s.txt.

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
en 0q. El epílogo sigue pendiente. No se declara MAP01 terminado.

## Validación de 4.33.0o

- GZDoom 4.14.2 compila y carga MAP01 nuevo y un guardado real de 0n sin
  errores de scripts ni de carga. No se repite la matriz de juego ya aprobada.
- El WAD contiene un único manual tipo 18106, en (-364,800,0); el guardado
  conserva ese mismo origen. El retiro apunta sólo a ese ejemplar del mundo,
  con un marcador independiente para migrar guardados ya preparados por 0n.
- WAD y demás archivos de runtime conservan su contenido; sólo cambia el
  controlador de MAP01. README y los cinco documentos quedan en versión 0o.
  ZIP cotejado contra 0n: siete archivos modificados y un TXT de pruebas.

Prueba del autor pendiente sólo para esta corrección: comprobar que el manual
exterior desaparezca y que se conserven las recetas aprendidas.

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

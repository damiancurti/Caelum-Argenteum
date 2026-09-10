# Caelum Argenteum — Proyecto, estado y roadmap

Versión documental: 4.33.0l — 2026-09-10.

## Estado actual

**4.33.0k aceptado:** el autor confirmó que todas las pruebas dieron bien.
Quedan aceptados Caella y sus runas, Detalle con F, limpieza de las seis salas,
y las correcciones anteriores de HUD, idioma, estaciones y audio.

**4.33.0l implementa elección, recolección y primera arma de Ronnie.** Ofrece
16 armas físicas y 20 variantes de esencia T1, independientemente de la clase.
Cada opción se explica antes de confirmar. Enseña la receta y sus dependencias;
presta la espada, incorpora tres arbustos 2D y un cofre de gemas/cuero de vaca.
El crafting real entrega el arma al inventario personal, sin adelantar la Caja.
Al volver, Ronnie retira sólo su espada. Se conserva la primera arma fabricada.

El cofre deriva sus cantidades de las recetas vigentes, al talle del personaje
y al 25% en todas las capas. Stock, elección, tareas e identidades persisten.
Detalle muestra faltantes, componentes ya disponibles y referencias del lugar.
No cambian recetas, costes de extracción, WAD, audio, HUD ni modelos aceptados.

La parte material llega a fase 60. **No acredita todavía toda la supervivencia
de la especificación:** faltan lecciones de comida, bebida, Aire, agua y una
reparación real; revisar el préstamo con Ronnie no equivale a esa reparación.
Rulo/Toro, Palomo final, Caja, El Loco y salida narrativa siguen por implementar.

Formato: sólo archivos nuevos/modificados para copiar, más un TXT de pruebas.
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
| 0 | Base hasta 4.33.0k | Aceptada por el autor: prólogo, Argento, Caella, geometría, HUD/audio, estaciones y Detalle. Migración 0h conservada. |
| 1 | 4.33.0l: materiales y primera arma, fases 50–60 | Implementado; validar elección libre, recetas, arbustos, cofre, préstamo, crafting y persistencia. |
| 2 | Completar enseñanza de supervivencia de Ronnie | Reparación real, alimento/agua, Aire y paso de agua seguro; integrar los objetivos antes de habilitar Rulo. Fijar valores tutoriales pendientes sin cambiar el balance general. |
| 3 | Rulo y Toro, fases 70–75 | Entrenamiento, combate y resolución; contemplar todas las armas elegibles y asignar munición tutorial a las que la requieren. |
| 4 | Palomo final, fase 80 | Aparición/ubicación final, cierre de las cuatro ramas y entrega única de la Caja Mágica. |
| 5 | El Loco y salida, fases 90–100 | Captura/recompensa única, transferir el arma elegida por ItemId, completar misión y transición narrativa. La limpieza técnica de temporales de 0l no implementa por sí sola esta salida. |
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

Con GZDoom cerrado, copiar src, assets, docs y README.md del parche sobre la carpeta
completa 0k y aceptar reemplazos. Combinar carpetas; no sustituir src por una
carpeta que contiene sólo el delta. Iniciar run_dev.bat para reconstruir y jugar.
El ZIP sólo contiene archivos nuevos/modificados y PRUEBAS_4_33_0l.txt.

Se conservan build_dev.ps1 y run_dev.bat existentes: construyen el juego, no
instalan parches. Se mantiene la migración 0h aceptada y las rutas del motor/IWAD
del autor. No se entregan ni ejecutan más aplicadores por versión. El TXT de
pruebas queda junto al ZIP; sus resultados se integran en estos cinco documentos.

## Validación de 4.33.0l

- GZDoom 4.14.2 compila y carga los 4.151 archivos de runtime sin errores ni
  advertencias nuevas. La matriz central pasó 102 comprobaciones: préstamo,
  cierre de Caella sin retirar la espada de Ronnie, receta/dependencias, stock,
  protección de suministros, resultados personales y primera arma por ItemId.
- Se compararon 180 planes (36 armas por cinco talles) con el blueprint real
  del motor, al 25% en cada capa. Coinciden todos; el cofre cubre cada opción.
  Los nodos existentes alcanzan los máximos: madera 336.000, cobre 4.838.400,
  estaño 537.600 y fibra 144.000 unidades. No se aumentaron vetas ni árboles.
- Se completaron 36 transacciones reales de crafting, una por elección en M,
  sin Caja Mágica. El ensayo inyecta materias primas y adelanta el reloj de la
  tarea para verificar reservas/salida; no acredita el ritmo de recolección ni
  la duración de una partida manual. Siete comprobaciones adicionales verifican
  procedencia temporal de un componente real, protección y cálculo de faltantes.
- Diez comprobaciones de interfaz nativa: Usar abre Ronnie y cofre, elegir
  Libro/Aire llega a la receta correcta y retirar topacio cambia el stock.
  Capturas revisadas: familias, explicación/confirmación, préstamo, ambas
  páginas del cofre, Detalle paginado y arbusto transparente en la cueva.
- 42 comprobaciones de persistencia y viaje, cero fallos: guardar con 0k en
  fase 45 y espada de cueva recogida; actualizar la misma instalación a 0l;
  adoptar esa instancia, retirar gemas y guardar con tarea/reservas activas;
  cargar, cancelar y devolver sólo suministros, preservando 123 unidades propias;
  fabricar, devolver la espada, guardar/cargar con arma inicial y una adicional;
  cambiar de mapa conservando la primera y retirando temporales. El arma activa
  temporal se sustituye por la inicial sin referencias a equipo destruido.
- La espada también se ensayó por la ruta real de ataque/LineAttack: el
  principal alcanza el arbusto y produce fibra; el secundario no la produce.
  La dispersión existente sigue aplicándose: hay que alcanzar la planta.
- README y cinco docs actualizados; validación de recursos/traducciones sin
  errores. WAD, 74 archivos de audio y modelos aceptados mantienen sus huellas.
  El ZIP se coteja contra 0k y sólo contiene el delta y su TXT de pruebas.

Pruebas del autor: recorrer una elección física y otra de esencia usando
guardados separados; recoger fibra con el principal de la espada y comprobar
que el secundario no la entrega; retirar/devolver suministros; fabricar en
la red exterior, por capas si hace falta; guardar/cargar antes y después de
devolver el préstamo. El TXT del ZIP contiene los pasos concretos.

Los ensayos usan una base reconstruida de 0k con archivos cotejados y GZDoom
4.14.2/OpenGL. No sustituyen la revisión visual/jugable en Windows del autor.
No incluyen pruebas de cooperativo. Motor, IWAD, fixtures y guardados de ensayo
permanecen fuera del parche. Registros técnicos de 0i–0k: HISTORY.md.

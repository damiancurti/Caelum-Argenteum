# Caelum Argenteum — Proyecto, estado y roadmap

Versión documental: 4.33.0ac — 2026-09-12.

## Estado actual: 4.33.0ac

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
La versión aprobada actual es 0w.
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
La distribución narrativa de conocimiento para armaduras/sellos aún falta.

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

Reparación, alimento/agua, Aire/movimiento, carga y respiración en piscina están
implementados como prácticas opcionales. Virotes y su conocimiento están
implementados en 0ac. Quedan recetas de armaduras/sellos, composición y receta
de balas y recolección/potabilización de agua; no bloquean las ramas aceptadas.

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
| 8 | Ampliaciones restantes del tutorial | Alimento/agua, Aire/movimiento y carga incluidos en la base 0aa aprobada. Respiración en piscina 0ab aprobada. Virotes y enseñanza a la ballesta implementados en 0ac, pendiente de prueba del autor. Quedan acceso a recetas de armaduras/sellos, definir composición/proceso de balas para su receta y recolección/potabilización de agua. La cobertura de cuero no garantiza todos los conjuntos a baja eficiencia; definir fuentes nuevas antes de prometerla. No bloquear ramas ya aceptadas. |
| 8a | Balance autorizado 0aa | Pasivas menores, barrido de armas grandes y divisores Tipo 4 aprobados por el autor. |
| 9 | Construcción de mapas y alcantarillas | Diferida por decisión del autor. Priorizar sistemas y pruebas en MAP01; conservar la llegada actual de MAP02 y CADEV02. |

La verdad autoral y las revelaciones futuras no deben filtrarse a los NPC del
inicio. MAP01.txt contiene la especificación completa y las correcciones que
prevalecen sobre su primera versión.

## Roadmap general por versiones

Esta es la secuencia ya planificada, reconciliada con lo implementado. Los
registros originales siguen completos en HISTORY.md. “Base implementada”
no significa que todo el contenido de ese sistema esté terminado.

| Hito | Estado y trabajo pendiente |
| --- | --- |
| V4.27: controles de combate | Rutas nativas implementadas: Fire/AltFire, Reload contextual, Zoom Block/ADS/barrido y User1–4. Completar/registrar la matriz pendiente por familia cuando corresponda; conservar lo aceptado. |
| V4.28: Channel de Sellos | Efectos actuales sin clima aceptados en 0bp. Extensiones dependientes de clima pasan a V5; no reabrir los efectos cerrados. |
| V4.29–V4.31: crafting y ciclo de equipo | Base de recetas, reservas, lotes, eficiencias independientes, reparación y desarme aceptada. Quedan distribución narrativa de conocimiento, recompensas/hojas/tiendas/descubrimientos y bonos de eficiencia todavía sin valores autorizados. |
| V4.31: recursos, botín y contenedores | Fuentes físicas y alijos tienen base; completar tablas de botín por planta/animal/monstruo, contenido/capacidad/propiedad/robo/reposición de contenedores y adquisición sistemática de materiales. La expansión persistente de biomas va en V5. |
| V4.32: NPC, comercio y primera persona | Use/USDF, transacciones, monedas y Caja aceptados. Falta comerciante canónico posterior y contenido de tiendas. Extender la vista modular de espada/manos/escudo 0o a las demás armas con arte propio. |
| V4.33: misiones, reputación y facciones | Registro por personaje aceptado; terminar MAP01, desarrollar misiones secundarias/cadenas y consecuencias jugables de pertenencia/reputación. Los cuatro dominios técnicos actuales no equivalen a las ocho facciones narrativas completas. |
| V4.34: arquitectura del mundo y viajes | Reutilizar módulos de habitación/escalera ya validados; puertas cerradas/con llave y pisos adicionales. Definir ubicaciones, conexiones, caravanas y puntos de integración de viajes/eventos. No confundir arquitectura de mapas con refactor de código. |
| V4.35: calendario, clima y eventos | Calendario/estaciones, duración del día, clima local y planificación de eventos/viajes. Después del reloj global, descanso y avance del tiempo con sus interrupciones; sillas/camas pueden reutilizar interacción, inmovilidad y cámara de seguimiento. Publicar un estado ambiental común de temperatura, viento, precipitación y humedad. El modelo térmico del personaje llega después. |
| V4.36: entorno móvil y peligros físicos | Rocas que ruedan, objetos que caen y superficies peligrosas; luego avalanchas, arietes, catapultas y sectores móviles mediante el núcleo físico. Extraer Impact Physics como paquete independiente sólo tras cerrar su validación en Caelum. |
| V4.37: Tarot y Trucazo | Colección iniciada en 0t y pasivas base de los 56 Menores implementadas en 0aa; activación de cartas poseídas/seleccionadas con User3 y costes/cooldowns; después contenido de cartas y minijuego Trucazo sobre inventario/NPC/eventos estables. |
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
completa 0ab y aceptar reemplazos. Combinar carpetas; no sustituir src por una
carpeta que contiene sólo el delta. Iniciar run_dev.bat para reconstruir y jugar.
El ZIP sólo contiene archivos nuevos/modificados y PRUEBAS_4_33_0ac.txt.

Se conservan build_dev.ps1 y run_dev.bat existentes: construyen el juego, no
instalan parches. Se mantiene la migración 0h aceptada y las rutas del motor/IWAD
del autor. No se entregan ni ejecutan más aplicadores por versión. El TXT de
pruebas queda junto al ZIP; sus resultados se integran en estos cinco documentos.

## Validación de 4.33.0ac

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
PRUEBAS_4_33_0ac.txt, sin ejecutores, escenas privadas ni PK3. Queda la prueba
del autor en Windows con sus guardados, controles y tiempos habituales.

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

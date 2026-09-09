# Caelum Argenteum — Misiones, reputación y facciones V4.33.0c

## Estado de la revisión

V4.33.0a y V4.33.0b fueron aceptadas después de superar íntegramente sus
matrices manuales en GZDoom 4.14.2. V4.33.0b sustituyó la aventura comercial de
prueba por la misión principal canónica de MAP01; V4.33.0c prepara sus actores
y espacios físicos sin adelantar las transiciones narrativas:

- ID estable: `QUEST_MAIN_M00_THE_FOOL`;
- nombre visible provisional: **Donde despiertan los perdidos**;
- recorrido completo reservado: fases 00–100;
- recorrido jugable: despertar, Voz desconocida, primer encuentro con Palomo y
  orientación hacia Argento;
- preparación física nueva: posiciones de los cuatro residentes y cueva de
  materiales tras el pasadizo secreto.

No se implementan todavía la prueba social de Argento ni las ramas de Caella,
Ronnie, preparación de arma, Rulo, Caja, El Loco o salida. Sus estados quedan
nombrados para evitar renumeraciones posteriores, pero ninguna transición los
activa antes de que exista su contenido. La cueva puede recorrerse y probarse
en esta revisión; todavía no completa objetivos ni concede progreso de Ronnie.

## Actores y espacios preparados en MAP01

| Actor o elemento | Ubicación | Contrato |
| --- | --- | --- |
| Argento | `(1040,-378,136)`, 90° | Tangible, anclado, pasivo |
| Caella | `(-290,-378,136)`, 90° | Tangible, anclada, pasiva |
| Rulo | `(-290,378,136)`, 270° | Tangible, anclado, pasivo |
| Ronnie | `(1036,378,136)`, 270° | Tangible, anclado, pasivo |
| Entrada falsa | `(1842,-360,0)`, 90° | Visible por ambas caras y atravesable |
| Segunda pared falsa | `(1944,-87,0)`, 180° | Visible por ambas caras y atravesable |
| Fondo | `(1842,366,0)`, 270° | Pared sólida |
| Ascensor | `(1917,316,0)`, 90° | Huella 84×88 MU; enlace de ida y vuelta |

La instrucción posterior del autor que exige NPC tangibles reemplaza para estas
cuatro instancias la frase “no bloqueables” de la especificación v1.0. Se
mantienen invulnerables y fuera del combate. `args[0]=1` activa el contrato
narrativo y almacena posición/ángulo de origen; al alcanzar 500 MU de
desplazamiento regresan corriendo en línea recta. Una invocación de depuración
sin ese argumento continúa funcionando como combatiente.

La cueva inferior es un recinto cerrado de 1000×800 MU, con tres árboles, una
veta de hierro, carbón, cobre y estaño, y una única hachuela T1 cuyo talle se
adapta al personaje al recogerla. Sus vetas tutoriales aceptan AltFire romo de
la hachuela. Esta excepción es local: no modifica el catálogo ni la extracción
perforante de ninguna veta normal.

## Separación de responsabilidades

| Componente | Responsabilidad |
| --- | --- |
| `CaelumPersistentCharacterState` | Etapa, objetivos y flags autoritativos que viajan con el personaje |
| `CaelumMainM00QuestController` | Reconstruir presentaciones pendientes de MAP01 desde el estado persistente |
| `CaelumPlayer` | Ejecutar transiciones, sincronizar el Diario y abrir conversaciones |
| `CAPALOMO` | Árboles USDF localizados de la Voz y Palomo |
| `CaelumJournalOverlay` | Mostrar una instantánea simple, sin llamadas de ámbito `play` durante el render |

El controlador de mapa no conserva progreso propio. Cargar, guardar o volver a
MAP01 siempre consulta el Inventory viajero; de ese modo una presentación
duplicada no puede otorgar progreso u objetos por segunda vez.

## Estados principales reservados

| Valor | Estado | Fase |
| ---: | --- | --- |
| 0 | `MAIN_M00_STATE_INITIALIZE` | Preparación |
| 10 | `MAIN_M00_STATE_AWAKENED` | Despertar y Voz desconocida |
| 20 | `MAIN_M00_STATE_MET_PALOMO` | Encuentro del recibidor |
| 30 / 35 | `ARGENTO_ACTIVE / COMPLETE` | Rama social |
| 40 / 45 | `CAELLA_ACTIVE / COMPLETE` | Rama mágica |
| 50 / 55 | `RONNIE_ACTIVE / COMPLETE` | Rama de supervivencia |
| 60 | `WEAPON_READY` | Preparación del arma |
| 70 / 75 | `RULO_ACTIVE / COMPLETE` | Rama de combate |
| 80 | `BOX_RECEIVED` | Palomo final y Caja |
| 90 | `FOOL_CAPTURED` | Captura de El Loco |
| 95 / 100 | `EXIT_CONFIRMED / COMPLETE` | Salida y cierre |

`TryAdvanceMainM00State(expected, next)` sólo acepta la etapa esperada y un
valor posterior. Las operaciones de apertura son idempotentes: repetir una
llamada no salta estados ni duplica recompensas.

## Objetivos y flags

Se mantienen los ocho objetivos por misión aceptados en V4.33.0a. Para MAP01
representan los hitos amplios: buscar ayuda, convencer residentes, resolver el
acertijo, reunir materiales, preparar el arma, derrotar al Toro, capturar El
Loco y abandonar la mansión. Las acciones más breves se expresan mediante la
etapa actual y claves localizadas; así no se cambia el tamaño de los arreglos
de guardado.

La tabla `MainM00Flag[64]` reserva los hechos descritos en la especificación:
progreso de cada rama, objetos únicos, acciones tutoriales, runas, pasadizo,
Toro, Caja, carta, salida y conocimiento de diálogo. En V4.33.0b sólo se mutan:

- `STARTED`;
- `UNKNOWN_VOICE_HEARD`;
- `PALOMO_MET`;
- las cuatro preguntas opcionales del recibidor;
- `PALOMO_CALLED_IT_HALLUCINATION` cuando se menciona la Voz.

El objetivo inicial comienza en 0/1 y pasa a 1/1 al terminar la conversación
del recibidor. La etapa queda entonces en `ARGENTO_ACTIVE`, cuyo texto visible
es **Hablar con Argento**.

## Migración desde V4.33.0a

La versión del registro sube de 1 a 2. El índice 0 se conserva, pero el relato
anterior era infraestructura de prueba y no una etapa canónica:

- se limpia únicamente aquel registro de misión y sus objetivos;
- al estar en MAP01, el controlador inicia el nuevo prólogo;
- la Caja ya poseída, sus 10 kg, contenido, slots, stock monetario y demás
  inventario no se eliminan ni duplican;
- tener una Caja de una partida antigua no salta la Voz ni el diálogo inicial;
- un personaje nuevo sigue comenzando sin Caja.

`GrantMagicBoxFromPalomo()` queda desacoplado del avance de misión. La entrega
canónica se conectará en la fase 80 junto con su flag propio; conceder la Caja
desde una herramienta de desarrollo ya no puede completar otra etapa.

`map MAP02` crea un personaje nuevo, mientras `Exit` o `changemap`
transfieren el existente. Esta distinción del motor no cambia.

## Ubicación autoritativa de Palomo

`ResolvePalomoPlacement()` produce tres resultados estables:

| Resultado | Condición |
| --- | --- |
| Oculto | Antes de oír la Voz y después de completar el encuentro del recibidor |
| Recibidor | Durante la fase 20 |
| Segundo piso | Reservado desde la fase 80 |

El Palomo anclado de MAP01 comienza invisible y sin colisión. Cuando cualquier
jugador elegible oye la Voz, aparece con un fundido breve, sin destello de
teletransporte, recupera colisión y conserva el retorno a su origen si lo
desplazan 500 MU. Después de orientar hacia Argento espera a quedar fuera de
todos los campos visuales, se oculta y una carga reconstruye ese resultado. El
traslado real al segundo piso necesita todavía el punto de mapa correspondiente.

## Facciones y reputación

La base aceptada en V4.33.0a no cambia:

| ID | Dominio técnico | Membresía inicial | Reputación inicial |
| ---: | --- | --- | ---: |
| 0 | Gendarmería | No | 0 |
| 1 | Asentamientos | No | 0 |
| 2 | Caravanas | No | 0 |
| 3 | Actores políticos | No | 0 |

Membresía y reputación siguen siendo variables independientes por personaje,
limitadas a -1000..1000. Las relaciones cruzadas no autorizadas permanecen
neutrales y la consulta O(1) no añade búsquedas de actores, visión ni pathfinding.
Las cinco acciones de consola de V4.33.0a continúan disponibles sólo para
validación aislada.

## Fuente narrativa

`docs/MAP01_HISTORIA_Y_PROGRAMACION_v1_0.txt` se incorpora sin alteraciones
como especificación autoral. Los textos visibles de este subparche preservan el
misterio: no identifican la naturaleza de la mansión, el destino del
protagonista ni a la mujer que habla.

# Inventario de audio — Caelum Argenteum 4.30.0j

Este inventario cuenta archivos físicos, no sólo alias lógicos. Después de
integrar el paquete 05, el proyecto conserva **83 archivos de audio aprobados**:
73 viajan en el PK3 y 10 permanecen como reserva externa. Hay 82 contenidos
únicos porque `ca_menu_move.ogg` y `ca_menu_select.ogg` son copias deliberadas
del mismo audio. Los dos archivos en cuarentena legal del paquete 05 no se
incluyen en estas cifras ni en los entregables.

| Estado | Archivos | Significado |
|---|---:|---|
| Evento automático actual | 27 | El código, una propiedad de actor o `TERRAIN` ya llama al evento. |
| Destino registrado | 34 | Está dentro del PK3 y declarado en `SNDINFO`, pero el sistema/emisor automático aún no existe o no está conectado. |
| Stock | 20 | No tiene evento aprobado: 10 legados están dentro del PK3 por compatibilidad y 10 nuevos quedan fuera de `src`. |
| Música | 2 | Pistas asignadas por `MAPINFO`. |
| **Total** | **83** | 71 OGG de efectos/ambiente + 10 OGG de reserva externa + 2 MP3 de música. |

## Eventos automáticos actuales — 27

| N.º | Nombre lógico | Archivo | Uso actual |
|---:|---|---|---|
| 1 | `caelum/ui/menu_open` | `sounds/caelum/ui/ca_menu_open.ogg` | Apertura del menú de creación. |
| 2 | `caelum/ui/menu_move` | `sounds/caelum/ui/ca_menu_move.ogg` | Movimiento en creación, Inventario y Oficios. |
| 3 | `caelum/ui/menu_select` | `sounds/caelum/ui/ca_menu_select.ogg` | Confirmación en creación, Inventario y Oficios. |
| 4 | `caelum/ui/recipe_learned` | `sounds/caelum/ui/ca_recipe_learned.ogg` | Aprendizaje de recetas. |
| 5 | `caelum/ui/crafting_page_turn` | `sounds/caelum/ui/ca_crafting_page_turn.ogg` | Cambio de familia/página de oficios. |
| 6 | `caelum/ui/map_transition` | `sounds/caelum/ui/ca_map_transition.ogg` | Transición de mapa. |
| 7 | `caelum/world/door_open` | `sounds/caelum/world/doors/ca_door_open.ogg` | Puerta normal. |
| 8 | `caelum/world/door_large_open` | `sounds/caelum/world/doors/ca_door_large_open.ogg` | Puerta grande. |
| 9 | `caelum/world/door_locked` | `sounds/caelum/world/doors/ca_door_locked.ogg` | Intento de abrir puerta cerrada. |
| 10 | `caelum/world/fire_loop` | `sounds/caelum/world/fire/ca_fire_loop.ogg` | Efecto elemental de fuego/burn. |
| 11 | `caelum/weapons/carabine_fire` | `sounds/caelum/weapons/ca_carabine_fire.ogg` | Disparo de carabina. |
| 12 | `caelum/items/pickup` | `sounds/caelum/items/ca_item_pickup.ogg` | Recogida general de objetos. |
| 13 | `caelum/items/weapon_pickup` | `sounds/caelum/items/ca_weapon_pickup.ogg` | Recogida de armas. |
| 14 | `caelum/player/low_health_heartbeat` | `sounds/caelum/player/ca_low_health_heartbeat.ogg` | Señal de salud baja. |
| 15 | `caelum/player/footstep_grass` | `sounds/caelum/player/footsteps/ca_footstep_grass.ogg` | Paso sobre césped mediante `TERRAIN`. |
| 16 | `caelum/enemies/zupay_alert` | `sounds/caelum/enemies/zupay/ca_zupay_alert.ogg` | Reconocimiento del Zupay. |
| 17 | `caelum/enemies/zupay_walk` | `sounds/caelum/enemies/zupay/ca_zupay_walk.ogg` | Movimiento del Zupay. |
| 18 | `caelum/enemies/mandinga_alert` | `sounds/caelum/enemies/mandinga/ca_mandinga_alert.ogg` | Reconocimiento del Mandinga. |
| 19 | `caelum/npcs/rulo_alert` | `sounds/caelum/npcs/rulo/ca_rulo_alert.ogg` | Reconocimiento de Rulo. |
| 20 | `caelum/player/footstep_wood_01` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_01.ogg` | Variante de paso sobre madera. |
| 21 | `caelum/player/footstep_wood_02` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_02.ogg` | Variante de paso sobre madera. |
| 22 | `caelum/player/footstep_wood_03` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_03.ogg` | Variante de paso sobre madera. |
| 23 | `caelum/player/footstep_wood_04` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_04.ogg` | Variante de paso sobre madera. |
| 24 | `caelum/player/footstep_wood_05` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_05.ogg` | Variante de paso sobre madera. |
| 25 | `caelum/player/footstep_wood_06` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_06.ogg` | Variante de paso sobre madera. |
| 26 | `caelum/player/footstep_wood_07` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_07.ogg` | Variante de paso sobre madera. |
| 27 | `caelum/player/footstep_wood_08` | `sounds/caelum/player/footsteps/wood/ca_footstep_wood_08.ogg` | Variante de paso sobre madera. |

Las ocho variantes de madera se seleccionan mediante el alias aleatorio
`caelum/player/footstep_wood`.

## Destinos registrados, pendientes de emisor o llamador — 34

| N.º | Nombre lógico | Archivo | Destino previsto |
|---:|---|---|---|
| 1 | `caelum/world/rain_loop` | `sounds/caelum/world/weather/ca_rain_loop.ogg` | Lluvia global del sistema meteorológico. |
| 2 | `caelum/player/swim_loop` | `sounds/caelum/player/movement/ca_swim_loop.ogg` | Natación sostenida. |
| 3 | `caelum/world/quintessence_seal_activate` | `sounds/caelum/world/seals/ca_quintessence_seal_activate.ogg` | Activación del sello de quintaesencia. |
| 4 | `caelum/world/quintessence_seal_deactivate` | `sounds/caelum/world/seals/ca_quintessence_seal_deactivate.ogg` | Desactivación del sello de quintaesencia. |
| 5 | `caelum/npcs/palomo_disappear` | `sounds/caelum/npcs/palomo/ca_palomo_disappear.ogg` | Desaparición de Palomo. |
| 6 | `caelum/player/level_up` | `sounds/caelum/player/progression/ca_level_up.ogg` | Subida de nivel. |
| 7 | `caelum/player/anima_restored` | `sounds/caelum/player/anima/ca_anima_restored.ogg` | Restauración de ánima. |
| 8 | `caelum/player/cough` | `sounds/caelum/player/status/ca_player_cough.ogg` | Tos del jugador. |
| 9 | `caelum/items/coin_pickup_01` | `sounds/caelum/items/currency/ca_coin_pickup_01.ogg` | Variante de recogida de moneda. |
| 10 | `caelum/items/coin_pickup_02` | `sounds/caelum/items/currency/ca_coin_pickup_02.ogg` | Variante de recogida de moneda. |
| 11 | `caelum/items/coin_pickup_03` | `sounds/caelum/items/currency/ca_coin_pickup_03.ogg` | Variante de recogida de moneda. |
| 12 | `caelum/items/coin_pickup_04` | `sounds/caelum/items/currency/ca_coin_pickup_04.ogg` | Variante de recogida de moneda. |
| 13 | `caelum/items/coin_pickup_05` | `sounds/caelum/items/currency/ca_coin_pickup_05.ogg` | Variante de recogida de moneda. |
| 14 | `caelum/items/coin_pickup_06` | `sounds/caelum/items/currency/ca_coin_pickup_06.ogg` | Variante de recogida de moneda. |
| 15 | `caelum/items/coin_pickup_07` | `sounds/caelum/items/currency/ca_coin_pickup_07.ogg` | Variante de recogida de moneda. |
| 16 | `caelum/items/coin_pickup_08` | `sounds/caelum/items/currency/ca_coin_pickup_08.ogg` | Variante de recogida de moneda. |
| 17 | `caelum/items/coin_pickup_09` | `sounds/caelum/items/currency/ca_coin_pickup_09.ogg` | Variante de recogida de moneda. |
| 18 | `caelum/items/coin_pickup_10` | `sounds/caelum/items/currency/ca_coin_pickup_10.ogg` | Variante de recogida de moneda. |
| 19 | `caelum/items/coin_pickup_11` | `sounds/caelum/items/currency/ca_coin_pickup_11.ogg` | Variante de recogida de moneda. |
| 20 | `caelum/items/coin_pickup_12` | `sounds/caelum/items/currency/ca_coin_pickup_12.ogg` | Variante de recogida de moneda. |
| 21 | `caelum/ambience/crowd_murmur` | `sounds/caelum/ambience/ca_ambience_crowd_murmur_loop.ogg` | Taberna, mercado o reunión numerosa. |
| 22 | `caelum/ambience/rio_waves` | `sounds/caelum/ambience/ca_ambience_rio_waves_loop.ogg` | Costa, ribera o Río de la Plata. |
| 23 | `caelum/ambience/fire` | `sounds/caelum/ambience/ca_ambience_fire_loop.ogg` | Fogón, chimenea, brasero o incendio localizado. |
| 24 | `caelum/ambience/fountain` | `sounds/caelum/ambience/ca_ambience_fountain_loop.ogg` | Fuente o patio de mansión. |
| 25 | `caelum/ambience/blacksmith` | `sounds/caelum/ambience/ca_ambience_blacksmith_loop.ogg` | Herrería, fragua o taller metalúrgico. |
| 26 | `caelum/ambience/sewer_water` | `sounds/caelum/ambience/ca_ambience_sewer_water_loop.ogg` | Alcantarilla, canal, desagüe o arroyo pequeño. |
| 27 | `caelum/weather/thunder_distant` | `sounds/caelum/weather/ca_weather_thunder_distant_01.ogg` | Trueno distante. |
| 28 | `caelum/weather/thunder_heavy` | `sounds/caelum/weather/ca_weather_thunder_heavy_01.ogg` | Trueno fuerte y cercano. |
| 29 | `caelum/weather/thunder_roomy` | `sounds/caelum/weather/ca_weather_thunder_roomy_01.ogg` | Trueno reverberante. |
| 30 | `caelum/weather/rain_soft` | `sounds/caelum/weather/ca_weather_rain_soft_loop.ogg` | Lluvia suave. |
| 31 | `caelum/weather/rain_steady` | `sounds/caelum/weather/ca_weather_rain_steady_loop.ogg` | Lluvia sostenida media. |
| 32 | `caelum/weather/rain_light` | `sounds/caelum/weather/ca_weather_rain_light_loop.ogg` | Lluvia ligera o transición. |
| 33 | `caelum/weather/rain_heavy` | `sounds/caelum/weather/ca_weather_rain_heavy_loop.ogg` | Tormenta fuerte. |
| 34 | `caelum/weather/wind` | `sounds/caelum/weather/ca_weather_wind_loop.ogg` | Pampa, exterior o corredor abierto. |

Las doce variantes de moneda ya forman el alias aleatorio
`caelum/items/coin_pickup`, pero todavía no existe un actor de moneda que lo
llame. Los tres truenos nuevos forman el alias `caelum/weather/thunder`. Los
ambientes y el clima del paquete 05 quedan registrados sin imponer bucles,
volumen, atenuación ni ubicación antes de implementar sus emisores.

## Stock completo — 20

### Stock legado dentro del PK3 — 10

| N.º | Nombre lógico | Archivo | Uso posible |
|---:|---|---|---|
| 1 | `caelum/stock/cricket` | `sounds/caelum/stock/ambient/ca_stock_cricket.ogg` | Noche o campo. |
| 2 | `caelum/stock/iron_gate` | `sounds/caelum/stock/world/ca_stock_iron_gate.ogg` | Reja o portón de hierro. |
| 3 | `caelum/stock/evil_laugh` | `sounds/caelum/stock/voices/ca_stock_evil_laugh.ogg` | Risa de criatura o antagonista. |
| 4 | `caelum/stock/piano_progression` | `sounds/caelum/stock/music/ca_stock_piano_progression.ogg` | Piano diegético. |
| 5 | `caelum/stock/npc_mumble_male` | `sounds/caelum/stock/voices/ca_stock_npc_mumble_male.ogg` | Murmullo masculino de PNJ. |
| 6 | `caelum/stock/menu_strings_start` | `sounds/caelum/stock/ui/ca_stock_menu_strings_start.ogg` | Apertura o transición de interfaz. |
| 7 | `caelum/stock/reveal_sting` | `sounds/caelum/stock/ui/ca_stock_reveal_sting.ogg` | Revelación o descubrimiento. |
| 8 | `caelum/stock/tarot_harp_loop` | `sounds/caelum/stock/music/ca_stock_tarot_harp_loop.ogg` | Tarot o escena mística. |
| 9 | `caelum/stock/war_drums` | `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Combate, asedio o marcha. |
| 10 | `caelum/stock/ghoul_laugh` | `sounds/caelum/stock/voices/ca_stock_ghoul_laugh.ogg` | Risa de necrófago o criatura. |

### Stock nuevo fuera del PK3 — 10

| N.º | Archivo de reserva | Uso sugerido |
|---:|---|---|
| 1 | `assets/audio_stock/pack05/sounds/music/ca_stock_piano_short_loop_01.ogg` | Piano diegético de salón, fonda o mansión. |
| 2 | `assets/audio_stock/pack05/sounds/horror/ca_stock_breath_stinger_01.ogg` | Proximidad espectral, maldición o drenaje de ánima. |
| 3 | `assets/audio_stock/pack05/sounds/reactions/ca_stock_slow_clap_01.ogg` | Reacción teatral de Palomo, Mandinga o audiencia. |
| 4 | `assets/audio_stock/pack05/sounds/voices_en/ca_stock_demonic_you_died_en.ogg` | Voz demoníaca en inglés; sólo si la lengua es intencional. |
| 5 | `assets/audio_stock/pack05/sounds/props/ca_stock_toilet_flush_01.ogg` | Cisternas, tuberías o sanitario coherente con la época. |
| 6 | `assets/audio_stock/pack05/sounds/music/ca_stock_piano_loop_02.ogg` | Piano de salón o mansión. |
| 7 | `assets/audio_stock/pack05/sounds/music/ca_stock_creepy_piano_stinger_01.ogg` | Presagio o mansión embrujada. |
| 8 | `assets/audio_stock/pack05/sounds/creatures/ca_stock_monster_scream_01.ogg` | Grito genérico de monstruo o élite. |
| 9 | `assets/audio_stock/pack05/sounds/ui/ca_stock_triumph_jingle_01.ogg` | Logro, misión o reputación. |
| 10 | `assets/audio_stock/pack05/sounds/music/ca_stock_dark_chords_01.ogg` | Presagio, ritual o transición oscura. |

## Música — 2

| N.º | Identificador | Archivo | Uso actual |
|---:|---|---|---|
| 1 | `CA_MUS01` | `music/CA_MUS01.mp3` | Título y MAP01. |
| 2 | `CA_MUS02` | `music/CA_MUS02.mp3` | MAP02. |

## Trazabilidad y publicación

- Catálogo original y selected-audio v3: `src/licenses/AUDIO_CREDITS.md`.
- Paquete 04: `src/licenses/AUDIO_PACK_04_CREDITS.md`.
- Paquete 05: `src/licenses/AUDIO_PACK_05_CREDITS.md`.
- Los 24 OGG integrables o de reserva del paquete 05 están en Vorbis a 48 kHz.
- Antes de una publicación comercial final todavía hay que sustituir, cuando
  sea posible, las previsualizaciones públicas por descargas originales
  autenticadas y repetir la verificación de huellas, formato, mezcla y bucles.

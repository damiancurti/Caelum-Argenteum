# Caelum Argenteum — Diálogos iniciales de MAP01 V4.33.0d

## Tecnología nativa

`GameInfo.AddDialogues` carga `CAPALOMO` en todos los mapas. La apertura usa
USDF, `Thing_SetConversation`, `Actor.StartConversation` y
`ConversationMenu` de GZDoom 4.14.2. No se superpone un menú de diálogo
propietario.

El archivo contiene dos conversaciones:

| ID | Interlocutor | Uso |
| ---: | --- | --- |
| 43300 | Voz desconocida | Apertura automática, mediante un hablante técnico invisible |
| 43200 | Palomo | Interacción física con `Use` en el recibidor |

El hablante invisible de la Voz sólo mantiene viva la conversación nativa y se
destruye al cerrarla. No existe como persona visible, no bloquea el mapa y no
guarda progreso. Q conserva el cierre equivalente a Atrás; Escape y mando
mantienen la conducta normal del motor.

## Apertura y Voz desconocida

Al confirmar un personaje nuevo en MAP01, el controlador:

1. activa **Donde despiertan los perdidos**;
2. aplica un fundido breve desde negro y un sonido tenue ya existente;
3. abre una sola vez `CA_DLG_M01_UNKNOWN_VOICE_WAKE`;
4. registra `UNKNOWN_VOICE_HEARD` al abrir correctamente el diálogo;
5. avanza a la fase 20 y permite que Palomo se revele.

La página presenta dos respuestas explícitas —**¿Quién sos?** y **¿Dónde
estoy?**— y una única salida nativa USDF, **[Guardar silencio.]**. V4.33.0c
retira la segunda copia explícita de esa salida. Ninguna opción altera el orden
de la misión. Cerrar con Q después de haber leído la primera intervención
tampoco repite la Voz: el hecho registrado es haberla oído, no haber elegido
una respuesta concreta.

Ninguna línea identifica a la mujer ni explica la naturaleza del lugar.

V4.33.0d corrige además las páginas que responden **¿Quién sos?** y **¿Dónde
estoy?**: cada una conserva un único **Continuar** mediante `goodbye` nativo.
Se retiraron sus dos copias explícitas `choice`; el cierre y el registro de
haber oído la Voz mantienen el mismo comportamiento. La validación debe
recorrer ambas respuestas, además del silencio ya aprobado.

## Primer diálogo de Palomo

Palomo comienza con:

> Buen día. O algo suficientemente parecido como para no discutir con el reloj.

El jugador puede preguntar, en cualquier orden:

- dónde se encuentran;
- qué le pasó;
- por qué no recuerda cómo llegó;
- por la voz de una mujer.

Cada pregunta agotada deja un flag persistente y se oculta durante esa
conversación y las siguientes. Mencionar la Voz registra además que Palomo la
calificó como una alucinación. Esa rama incluye la réplica opcional **No parece
una alucinación** y la respuesta prescrita **Las buenas nunca lo parecen**. Las
respuestas son corteses, metafóricas y evasivas, y nunca convierten la
interpretación del autor en conocimiento del personaje.

**¿Qué debería hacer?** puede elegirse sin agotar las preguntas opcionales.
Palomo sugiere hablar con Argento y explica, sin formular una orden directa,
que señalar cada baldosa convertiría el camino en el suyo. Esa respuesta:

- completa **Buscar ayuda dentro de la propiedad** en 1/1;
- registra `PALOMO_MET`;
- avanza exactamente de fase 20 a `ARGENTO_ACTIVE`;
- actualiza el Diario y guarda el personaje;
- sustituye cualquier segunda activación inmediata por una línea ambiental que
  recuerda a Argento.

Una segunda activación no repite la presentación ni concede otra transición.
Al cerrar, Palomo permanece mientras cualquier jugador todavía pueda verlo; al
quedar fuera de todos los campos visuales se oculta sin destello y no reaparece
en el recibidor. Una carga posterior reconstruye directamente ese resultado.

## Palomo y el comercio

Palomo no es comerciante en la historia. `CAPALOMO` ya no ofrece comerciar,
pedir rebaja ni recibir la Caja al comienzo. Las clases del comercio, su stock,
monedas, márgenes y menú permanecen intactos como infraestructura reutilizable
para un NPC comerciante posterior y para pruebas aisladas; no tienen una ruta
de acceso desde el diálogo canónico de Palomo.

Las viejas claves localizadas y acciones de respuesta se conservan por
compatibilidad con guardados que pudieran haberse realizado dentro de la
conversación de V4.33.0a. No definen el comportamiento de una partida nueva.

## Persistencia

USDF consulta marcadores invisibles regenerados desde
`CaelumPersistentCharacterState`. Los marcadores sólo deciden qué nodo
mostrar; no son una segunda fuente de verdad. Las etapas y preguntas sobreviven
guardado/carga y `Exit`/`changemap`. El actor físico puede perder su nodo
temporal al cerrar y volver a sincronizarlo en la próxima pulsación de `Use`.

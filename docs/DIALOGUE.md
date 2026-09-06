# Caelum Argenteum — Diálogo nativo de Palomo V4.32.0d

## 1. Tecnología del motor

La conversación usa el formato USDF y `ConversationMenu` nativos de GZDoom
4.14.2. `GameInfo.AddDialogues` carga `CAPALOMO` en cada mapa. Al pulsar `Use`,
el jugador sincroniza marcadores invisibles de inventario, asigna temporalmente
el ID 43200 mediante `Thing_SetConversation` y llama a
`Actor.StartConversation`. Al cerrar, Palomo libera el nodo temporal para que
la siguiente pulsación vuelva a pasar por el control autoritativo del jugador.

Se aprovechan directamente estas funciones del motor:

- páginas y enlaces USDF;
- respuestas ocultas mediante `require` y `exclude`;
- salto de página mediante `ifitem`;
- acciones atómicas de respuesta mediante `giveitem`/`TryPickup`;
- cierre, selección y respuesta en el `ConversationMenu` nativo.

Q se traduce a la acción nativa Atrás para mantener el control ya aceptado en
los demás paneles. Escape y el botón Atrás del mando conservan su conducta
normal del motor.

## 2. Árbol antes de obtener la Caja Mágica

1. Palomo se presenta como un palomo y dueño de la mansión.
2. Pregunta si el jugador quiere una aventura.
3. **Sí:** entrega una vez la Caja Mágica y explica que servirá para la aventura.
4. **No:** pregunta si está seguro.
5. **Sí, estoy seguro:** responde “Qué lástima”, cierra y no entrega la Caja.
6. **No, cambié de idea:** entrega la Caja y muestra el mismo mensaje de regalo.

El rechazo definitivo no se guarda como fracaso permanente porque no se
autorizó una consecuencia irreversible. Mientras no posea la Caja, una futura
conversación vuelve a ofrecer la aventura.

## 3. Árbol después del regalo

Palomo pregunta “¿Qué querés?” y ofrece:

- **Comerciar:** cierra el diálogo y abre la interfaz bilateral ya aceptada.
- **Hablar:** muestra la primera línea social de Palomo y permite volver.
- **Pedir una rebaja:** sólo aparece con Elocuencia cruda mayor que 50 y se
  oculta tras lograr el acuerdo.

La opción de rebaja muestra dificultad 50 y la probabilidad antes de confirmar.
La estadística usada es la Labia autoritativa:

```text
Labia = Elocuencia × (Elocuencia + 1) / 101
probabilidad = piso(Labia / 50 × 100), limitada a 0..100
éxito automático si Labia >= 50
```

La tirada usa el flujo aleatorio nombrado `CaelumPalomoDiscount`. Un fallo no
añade castigos ni bloqueos no especificados y permite otro intento. Un éxito
persiste en `CaelumPersistentCharacterState` y cambia únicamente los márgenes
de Palomo: cobra 140% y paga 60% del valor base del lote.

## 4. Persistencia y movimiento futuro

Propiedad de la Caja, stock, caja monetaria y rebaja pertenecen al personaje,
no a la instancia física de Palomo. Por ello V4.33 podrá destruir, teletransportar
o recrear al NPC según la etapa de misión, incluso en otro mapa, sin duplicar
dinero ni reiniciar el acuerdo. Lo único pendiente para esa versión es definir
y ejecutar la regla de ubicación por estado de misión.


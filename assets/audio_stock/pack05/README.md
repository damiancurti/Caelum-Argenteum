# Reserva de audio — paquete 05

Estos 10 archivos pasaron la validación técnica y tienen licencias compatibles,
pero todavía no poseen un evento aprobado en Caelum Argenteum. Se guardan fuera
de `src/`, por lo que `tools/build_pk3.py` no los incorpora al juego y no
alteran ningún sonido actual.

Para aprobar uno:

1. definir la escena o evento concreto;
2. moverlo a una ruta estable bajo `src/sounds/caelum/`;
3. declararlo con un nombre lógico en `src/SNDINFO`;
4. probar mezcla, repetición, distancia y convivencia con música/diálogo;
5. conservar el crédito incluido en `src/licenses/AUDIO_PACK_05_CREDITS.md`.

No se copiaron los dos archivos en cuarentena legal del paquete original.

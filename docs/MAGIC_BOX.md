# Caelum Argenteum — Caja Mágica V4.32.0d

V4.32.0a-r4 sigue siendo la base de peso y almacenamiento aceptada. V4.32.0b
cambia la adquisición: un personaje nuevo ya no posee la Caja Mágica al
comenzar. V4.32.0d formaliza el regalo dentro del diálogo USDF nativo de
Palomo; la recompensa continúa siendo única y persiste en guardados y viajes.

## 1. Naturaleza y peso propio

La Caja Mágica es una capacidad persistente del personaje una vez recibida. No
existe como objeto seleccionable: no puede soltarse, venderse, destruirse ni
guardarse dentro de sí misma. Antes de recibirla no aporta peso, no ofrece
slots y ninguna ruta de pickup, crafting o interfaz puede guardar objetos en
ella. Al recibirla, su estructura aporta **10,000 kg** a la carga incluso
cuando está vacía.

La cantidad máxima de slots continúa derivándose de Inteligencia. Cada pieza
individual de equipo y cada pila admitida consume un slot, sin importar cuántas
unidades contenga la pila.

## 2. Reducción de peso

El contenido no pierde todo su peso. La carga se calcula con una sola operación
agregada:

```text
peso reducido del contenido =
    piso_a_0,001 kg(peso real total guardado / slots máximos actuales)

peso total de la Caja Mágica =
    10,000 kg + peso reducido del contenido
```

Se usan los **slots máximos**, no los ocupados. Todos los objetos y pilas se
suman antes de dividir y redondear. Esto evita que separar un mismo peso entre
varias pilas elimine carga mediante redondeos individuales.

Ejemplo: con 20 slots máximos y 10,000 kg reales guardados, el contenido aporta
0,500 kg y la caja completa aporta 10,500 kg. Con 0,380 kg guardados, el
contenido aporta 0,019 kg.

## 3. Contenido y restricciones

Se conservan las reglas existentes:

- equipo, consumibles, materiales, monedas, objetos clave admitidos y la pila
  personalizada de munición pueden guardarse;
- las llaves comunes no pueden guardarse, porque GZDoom comprueba su posesión
  nativa para puertas y `LOCKDEFS`;
- flechas y virotes nativos permanecen en el inventario personal;
- una pila completa sigue contando como un único slot, pero todas sus unidades
  aportan al peso real previo a la reducción;
- las monedas guardadas conservan íntegramente su valor y participan del peso
  reducido como cualquier otra pila.

## 4. Transacciones y cambios de capacidad

Recoger, depositar, recuperar, equipar, fabricar y desarmar evalúan la carga
final completa. Una operación se rechaza si, después de retirar el peso de su
ubicación anterior y añadirlo a la nueva, la carga superaría la capacidad del
personaje. Mover un objeto del inventario personal a la caja continúa permitido
cuando libera carga.

Si un cambio de Inteligencia reduce los slots máximos por debajo de los ya
ocupados, el contenido se conserva: no se elimina ni se expulsa. Se recalculan
de inmediato el divisor y la carga, y se bloquean nuevos depósitos hasta que la
ocupación vuelva a estar dentro del máximo. Recuperar o soltar contenido sigue
siendo la vía para liberar slots.

## 5. Interfaz

El Inventario muestra `slots usados/máximos` y el peso total actual de la caja,
incluidos sus 10,000 kg propios. La línea general de Carga incorpora exactamente
el mismo valor. El peso individual seleccionado continúa mostrando el peso real
del objeto o pila antes de la reducción. El icono 64×64 suministrado se muestra
junto a esta línea; antes del regalo aparece atenuado con el texto `No
adquirida`. Intentar almacenar desde Inventario antes del regalo devuelve una
causa explícita y no cambia el objeto.

## 6. Adquisición y compatibilidad de guardados

- Un perfil nuevo se marca explícitamente como no propietario.
- El primer `Use` sobre Palomo abre su presentación. Responder Sí a la aventura
  concede la Caja; responder No y luego reconsiderar también la concede.
- Confirmar que no se desea la aventura termina con “Qué lástima” y no entrega
  la Caja. Volver a hablar reofrece la decisión; no se inventa un rechazo
  permanente.
- El regalo añade sus 10 kg, habilita los slots y sólo puede ejecutarse una vez.
- Después de poseerla, hablar con Palomo abre las opciones Comerciar, Hablar y
  la prueba de rebaja si se cumple su requisito.
- La propiedad viaja en `CaelumPersistentCharacterState` y es independiente de
  la ubicación física futura de Palomo.
- Los perfiles confirmados creados antes de V4.32.0b conservan la Caja durante
  la migración. Esto evita perder acceso a contenido que ya estaba guardado.
- Una partida intermedia malformada que no posea la recompensa pero contenga
  banderas `InMagicBox` se sanea moviendo esas pilas al inventario personal; no
  se elimina ningún objeto.

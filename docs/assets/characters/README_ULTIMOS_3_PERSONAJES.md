# Caelum Argenteum — últimos tres personajes

Paquete listo para entregar al programador. Incluye todos los atlas y todos los
cuadros individuales de Palomo, Mandinga y Zupay Colosal.

## Inventario

| Personaje | Celdas | Atlas | PNG individuales |
| --- | ---: | ---: | ---: |
| Palomo | 256 × 256 px | 7 | 224 |
| Mandinga | 256 × 256 px | 1 | 54 |
| Zupay Colosal | 416 × 416 px | 2 | 102 |
| **Total** |  | **10** | **380** |

Cada carpeta conserva su README y manifiesto específico, con el orden exacto de
columnas, filas, nombres de estados, origen visual y tiempos sugeridos.

## Direcciones compartidas

Las filas siguen este orden: `front`, `front_left`, `left`, `back_left`, `back`,
`back_right`, `right`, `front_right`.

## Uso en el motor

- Importar los PNG como RGBA de 32 bits, sin hornear un color de fondo.
- No reescalar al importar. Ajustar el tamaño de mundo desde la definición del actor.
- Para Palomo y Mandinga, conservar la celda de 256 × 256 px.
- Para el Zupay de 3 m, conservar la celda de 416 × 416 px; el mayor tamaño ya
  incorpora su relación visual con un humano de 1,8 m.
- Usar filtrado lineal o trilineal. Si aparecen halos, revisar mipmaps y
  premultiplicación de alfa antes de editar las imágenes.
- Las cajas de colisión deben derivarse del torso y los pies, no del ancho total
  de la celda transparente.

## Acción nueva del Zupay

`Zupay_Colosal/ca_enemy_zupay_colossus_object_actions.png` contiene 6 columnas ×
8 direcciones: `lift_reach`, `lift_raise`, `lift_hold`, `throw_windup`,
`throw_release`, `throw_recover`.

La roca aparece una vez en los cinco primeros cuadros y ya no aparece en el sexto.
Generar el proyectil al pasar de `throw_release` a `throw_recover`, evitando que la
roca se duplique en la mano y en vuelo.

## Verificación realizada

- 380/380 cuadros individuales presentes y no vacíos.
- Todos los cuadros tienen el tamaño esperado y canal RGBA.
- 10 atlas presentes con dimensiones verificadas.
- Archivo ZIP comprobado mediante lectura integral y prueba CRC.

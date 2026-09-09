# Caelum Argenteum — revisión de perspectiva y guanteletes

Este parche contiene 99 PNG: 49 variantes Tier 2, 49 variantes Tier 3 y el icono base corregido `ca_giant_gauntlets.png`. Conserva los nombres y las subcarpetas del parche anterior.

## Cambios de esta revisión

Los guanteletes gigantes muestran una pareja completa. Cada mano tiene cuatro dedos consecutivos en la fila de nudillos y un pulgar lateral. El meñique ocupa el borde exterior, junto al anular, y es más corto; los pulgares apuntan hacia el espacio entre ambas manos. Esta anatomía se aplica al icono base y a T2/T3.

Los adornos de los 98 iconos de tier fueron redibujados como herrajes, broches o grabados integrados. Su inclinación, curvatura, relieve, zonas ocultas y luz acompañan la superficie del objeto. Las bandas rodean mangos, muñecas y tobillos; las placas de torso, casco, arma a distancia y libro siguen su plano correspondiente.

| Equipo | Ubicación del adorno |
| --- | --- |
| Armadura de torso | Pecho izquierdo del portador; lado derecho al mirar el icono |
| Botas | Un adorno por tobillo |
| Guantes y guanteletes | Un adorno por muñeca |
| Cascos | Placa frontal sobre la abertura del rostro |
| Armas blancas y de asta | Mango o encastre inmediato al filo, punta o cabeza |
| Armas a distancia | Costado de culata, caja, empuñadura o soporte |
| Objetos mágicos | Soporte secundario que deje visible el foco y el detalle principal |
| Escudos | Heráldica integrada en la cara del escudo |
| Amuletos y sellos | Montura metálica que rodea la gema o emblema |

T2 conserva plata envejecida, guardas pampeanas, laureles y acentos celeste/blanco. T3 añade más trabajo de plata, oro selectivo y motivos del Sol de Mayo. Se mantiene la estética oscura y semirrealista del proyecto.

## Instalación

1. Descomprime el ZIP.
2. Copia el contenido de `Caelum_Argenteum_tiers_2_3_argentinos_PATCH/icons/` en `graphics/caelum/icons/`.
3. Conserva la subcarpeta `jewelry/` y reemplaza los PNG con los mismos nombres.
4. Mantén esos mismos nombres y rutas si trabajas dentro de un PK3.

El código existente debe seguir apuntando a `ca_nombre_t2.png` y `ca_nombre_t3.png`. Este paquete es una actualización gráfica; no incluye cambios de estadísticas, recetas ni clases.

## Formato y uso

| Propiedad | Valor y finalidad |
| --- | --- |
| Archivo | PNG RGBA, 8 bits por canal; color y transparencia real |
| Lienzo | 128 × 128 px por icono |
| Área visible | Hasta 112 × 112 px, manteniendo la proporción original |
| Margen | Aproximadamente 8 px para proteger remates y bordes al escalar |
| Uso | Iconos de inventario, equipo, comercio y menús |
| Fondo | Transparente; el verde de trabajo no forma parte del PNG final |

128 × 128 es el tamaño de entrega acordado para este inventario. Permite conservar textura y adornos con un coste moderado: unos 64 KiB por icono RGBA sin comprimir, antes de estructuras adicionales del motor. El área de 112 px mantiene una escala visual uniforme y deja margen para puntas, cintas y bordes.

El tamaño del archivo no determina por sí solo las dimensiones físicas de un objeto en el mundo ni el tamaño de dibujo del HUD. El programador debe conservar la escala de presentación ya utilizada por el inventario y evitar deformar el icono al dibujarlo. Estos PNG no son animaciones de manos ni sprites direccionales de personajes.

## Archivos de consulta

- `MANIFEST_TIERS.csv`: nombres, rutas de instalación, tiers, colocación y formato.
- `CHECKSUMS_SHA256.txt`: integridad de los archivos.
- `VALIDACION.txt`: alcance de la comprobación realizada.
- `REGISTRO_GENERACION.json`: instrucciones de las ediciones y referencias de trabajo.
- `previews/preview_tier2.png` y `preview_tier3.png`: vistas completas de cada tier.
- `previews/preview_comparacion_t1_t2_t3.png`: ejemplos ordenados de izquierda a derecha.
- `previews/preview_guanteletes.png`: base, T2 y T3 ampliados.

Las láminas de `previews/` son para revisión y no deben copiarse como iconos del juego. La validación del paquete cubre las imágenes y el ZIP; no incluye una ejecución dentro del motor.


# Sistema tipográfico — Caelum Argenteum

La identidad usa una familia coordinada de cuatro funciones. El logotipo conserva su lettering propio y no debe reconstruirse escribiendo el nombre con estas fuentes.

| Fuente | Uso principal |
| --- | --- |
| `CaelumDisplay` | títulos, episodios, cartas de arcano y opciones principales |
| `CaelumText` | diálogos, objetivos, inventario y menús secundarios |
| `CaelumSmall` | ayudas, etiquetas compactas y texto de baja jerarquía |
| `CaelumMono` | HUD, contadores, estadísticas, consola y depuración |

El PK3 también incluye copias con los nombres estándar `BigFont`, `SmallFont`, `ConsoleFont` e `IndexFont`, además de los alias modernos `NewSmallFont`, `NewConsoleFont`, `AlternativeSmallFont` y `AlternativeBigFont`, para sustituir la tipografía general de GZDoom 4.14.2. Los glifos son PNG blancos y traducibles por los colores de texto del motor; plata y oro se eligen en ZScript/MENUDEF, no se hornean dentro de las letras.

Todos los PNG usan una celda transparente de altura fija y una línea base compartida. Los recortes de altura variable quedan prohibidos porque GZDoom los alinearía por su borde superior.

## Cobertura

ASCII imprimible y Latin-1 completo: mayúsculas, minúsculas, cifras, puntuación, `ÁÉÍÓÚÜÑ`, `áéíóúüñ`, `¿` y `¡`.

## Instalación

1. Añadir `Caelum_Argenteum_Typography.pk3` después del IWAD y antes de paquetes que también reemplacen fuentes.
2. En código propio, solicitar `CaelumDisplay`, `CaelumText`, `CaelumSmall` o `CaelumMono` por nombre.
3. Verificar menús a 640×360 y HUD a 320×200 antes de cerrar tamaños y espaciados.

## Dirección visual

- Serif romana sobria para relacionarse con el isologotipo y la gráfica institucional rioplatense.
- Contraste moderado: conserva el carácter editorial sin perder trazos al reducirse.
- Nada de runas, textura envejecida ni ornamentos dentro del texto corriente.
- Plata para información normal; oro reservado para arcanos mayores, selección y jerarquía excepcional.

## Licencia y procedencia

Prototipo bitmap derivado de DejaVu Serif, DejaVu Serif Bold y DejaVu Sans Mono. La licencia y avisos de redistribución se incluyen en `licenses/DejaVu-copyright.txt` dentro del paquete. El generador reproducible es `build_caelum_fonts.py`.

## Estado

La revisión V4.28.0as reduce las métricas del HUD, corrige la línea base e incorpora los alias modernos del motor. Debe verificarse en GZDoom 4.14.2 dentro del HUD, creación de personaje, menú y consola antes de fijar definitivamente tamaños y espaciados.

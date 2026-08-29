# Sistema tipográfico — Caelum Argenteum

La identidad usa una familia coordinada de cuatro funciones. El logotipo conserva su lettering propio y no debe reconstruirse escribiendo el nombre con estas fuentes.

| Fuente | Uso principal |
| --- | --- |
| `CaelumDisplay` | títulos, episodios, cartas de arcano y opciones principales |
| `CaelumText` | diálogos, objetivos, inventario y menús secundarios |
| `CaelumSmall` | ayudas, etiquetas compactas y texto de baja jerarquía |
| `CaelumMono` | HUD, contadores, estadísticas, consola y depuración |

El PK3 también incluye copias con los nombres estándar `BigFont`, `SmallFont`, `ConsoleFont` e `IndexFont`, además de alias modernos para las interfaces que sí aceptan fuentes del juego. Los glifos son PNG blancos y traducibles por los colores de texto del motor; plata y oro se eligen en ZScript/MENUDEF, no se hornean dentro de las letras. GZDoom 4.14.2 carga su `NewSmallFont` nativa directamente desde `gzdoom.pk3` para los renglones de `OptionMenu`, por lo que un mod PK3 no puede sustituir la fuente de Personalizar controles y otras páginas de opciones.

Todos los PNG usan una celda transparente de altura fija y una línea base compartida. Los recortes de altura variable quedan prohibidos porque GZDoom los alinearía por su borde superior. Desde V4.29.0y cada celda se rasteriza al doble de resolución física y su `font.inf` declara `Scale 2`; GZDoom conserva las dimensiones lógicas anteriores mientras dispone de cuatro veces más píxeles para filtrar cada glifo.

## Cobertura

ASCII imprimible y Latin-1 completo: mayúsculas, minúsculas, cifras, puntuación, `ÁÉÍÓÚÜÑ`, `áéíóúüñ`, `¿` y `¡`.

## Instalación

1. Añadir `Caelum_Argenteum_Typography.pk3` después del IWAD y antes de paquetes que también reemplacen fuentes.
2. En código propio, solicitar `CaelumDisplay`, `CaelumText`, `CaelumSmall` o `CaelumMono` por nombre.
3. Verificar menús a 640×360 y HUD a 320×200 antes de cerrar tamaños y espaciados. La resolución física 2x no autoriza cambiar posiciones o avances lógicos.

## Dirección visual

- Serif romana sobria para relacionarse con el isologotipo y la gráfica institucional rioplatense.
- Contraste moderado: conserva el carácter editorial sin perder trazos al reducirse.
- Nada de runas, textura envejecida ni ornamentos dentro del texto corriente.
- Plata para información normal; oro reservado para arcanos mayores, selección y jerarquía excepcional.

## Licencia y procedencia

Prototipo bitmap derivado de DejaVu Serif, DejaVu Serif Bold, DejaVu Sans Mono y DejaVu Sans Mono Bold. La licencia y avisos de redistribución se incluyen en `licenses/DejaVu-copyright.txt` dentro del paquete. `tools/rebuild_4_29_0y_fonts.py` reconstruye las doce carpetas desde los TTF de DejaVu y conserva la cobertura y métricas lógicas.

## Estado

La revisión V4.28.0az reduce el kerning directo a `-4`, recorta una columna transparente derecha de cada glifo y suma otro píxel a `SpaceWidth`. V4.29.0l aumenta únicamente la separación de palabra de `CaelumText` y sus alias de menú pequeño de 6 a 8 píxeles; no cambia el kerning entre letras, `CaelumSmall`, `CaelumDisplay` ni `CaelumMono`. V4.29.0y vuelve a rasterizar los 2.268 glifos a resolución física 2x, conserva exactamente el ancho y alto lógico de V4.29.0x y traslada la escala a cada `font.inf`. `FONTDEFS` ya no define fuentes `Template`, porque ese formato no lee `Scale` y duplicaría el tamaño visible. V4.29.0z sustituye los cinco rótulos gráficos del menú principal por `TextItem` localizados con `CaelumText`. Los renglones nativos de carga/guardado y `OptionMenu` conservan `NewSmallFont`; corregirlos exige una interfaz propia o un ejecutable derivado, no otro alias dentro del PK3.

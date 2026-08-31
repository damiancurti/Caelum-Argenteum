# Caelum Argenteum — Guía de tamaños gráficos

Esta guía documenta los tamaños adoptados para los recursos gráficos del proyecto, por qué se eligieron y cómo deben utilizarse al integrarlos en el juego.

## Resumen rápido

| Recurso | Tamaño de archivo | Contenido visible recomendado | Uso principal |
|---|---:|---:|---|
| Iconos de objetos, equipo y materiales | 128×128 px, PNG RGBA | Hasta 112×112 px, centrado | Inventario, equipo, fabricación, botín y vistas del HUD |
| Cuadro individual de personaje | 256×256 px, PNG RGBA | Altura objetivo aproximada: 176 px | Actor en el mundo, rotaciones y animaciones |
| Hoja completa de cada protagonista | 1536×2304 px, PNG RGBA | 6 columnas × 9 filas de celdas de 256×256 px | Archivo maestro, revisión y recorte; no sustituye los cuadros individuales al integrar en GZDoom |
| Texturas de escenario | Tamaño nativo según el módulo | Debe llenar el lienzo si es una textura repetible | Paredes, pisos, techos y alcantarillas |
| Componentes de interfaz | Tamaño nativo del componente | Según anclaje o regla de nueve segmentos | HUD, paneles, botones, marcos y diario |

## 1. Qué significa el tamaño del lienzo

El tamaño del PNG no equivale al tamaño físico que tendrá el elemento dentro del juego.

- **Lienzo:** superficie total y transparente del archivo, por ejemplo 128×128 o 256×256 px.
- **Dibujo visible:** zona ocupada por el objeto o personaje dentro de ese lienzo.
- **Escala en el juego:** tamaño final determinado por la definición del actor, el HUD o la textura; no se obtiene cambiando cada PNG por separado.

Usar lienzos uniformes facilita conservar centros, pies, puntos de giro, armas y efectos en la misma posición. También evita saltos visuales entre cuadros de una animación.

## 2. Iconos: 128×128 px

### Por qué se eligió

128×128 conserva los detalles de la estética semirrealista y oscura del proyecto —metal, cuero, vidrio, grabados y materiales— sin cargar cada elemento con la memoria y el peso innecesarios de un lienzo de 256×256.

Es además un tamaño de potencia de dos, conveniente para una canalización gráfica estable. GZDoom admite otros tamaños, por lo que no es una obligación técnica, pero normalizar los iconos simplifica el inventario, el escalado y el control de calidad.

El dibujo se mantiene, en general, dentro de una caja visible de hasta 112×112 px. Esto deja un margen mínimo aproximado de 8 px arriba y abajo, además de aire lateral según la forma. Ese espacio tiene tres funciones:

- impedir que puntas, armas, asas o textos queden cortados;
- mantener una escala óptica coherente entre objetos anchos y altos;
- permitir resplandor, sombra o contorno sin tocar el borde del archivo.

### Para qué se usa

- inventario y cuadrículas de equipo;
- materiales de fabricación;
- munición, consumibles, llaves y objetos de misión;
- vistas previas de botín o recogida;
- representaciones pequeñas en el HUD.

El icono maestro debe conservarse en 128×128. La interfaz puede mostrarlo a 64, 80, 96 o 128 px según el diseño, pero conviene reducirlo desde el maestro y no crear versiones independientes con encuadres distintos.

### Por qué no 64×64 o 256×256

- **64×64:** resulta demasiado ajustado para materiales finos, cadenas, filos, sellos y texto legible; también deja poco margen para reconstruir piezas que sobresalen.
- **256×256:** ofrece escasa mejora visible en una casilla de inventario normal, pero cuadruplica el número de píxeles respecto de 128×128.

## 3. Personajes: cuadros de 256×256 px

### Por qué se eligió

Cada cuadro de Rulo, Ronnie, Argento y Caella usa un lienzo RGBA de 256×256 px. El personaje tiene una altura visual objetivo aproximada de 176 px y se apoya sobre una línea de suelo común cercana a `y = 244`.

El espacio restante no está desperdiciado: permite contener armas largas, movimientos amplios, golpes, dolor, caída y efectos elementales sin cortar la cabeza, los pies, el hacha, la espada, el mangual o el bastón. La anchura de seguridad aproximada es de hasta 224 px.

El mismo lienzo para las cuatro razas también mantiene estable el punto de apoyo. La diferencia física entre ellas debe definirse mediante su silueta y la escala del actor en el juego. Por ejemplo, Rulo puede verse más corpulento y Caella más baja sin alterar el tamaño del PNG ni desplazar los pies entre cuadros.

### Para qué se usa

Son sprites de actores vistos dentro del mundo. Cada personaje contiene:

| Cuadros | Organización | Uso |
|---:|---|---|
| 48 | 8 direcciones × 6 acciones | `idle`, `move`, `walk`, `run`, `attack` y `pain` |
| 6 | Una secuencia común, rotación 0 | Animación de muerte |
| 54 | Total por personaje | Conjunto completo de animación |
| 216 | 54 × 4 personajes | Rulo, Ronnie, Argento y Caella |

Las rotaciones se numeran así:

| Rotación | Dirección |
|---:|---|
| 1 | Frente |
| 2 | Frontal izquierda |
| 3 | Izquierda |
| 4 | Posterior izquierda |
| 5 | Espalda |
| 6 | Posterior derecha |
| 7 | Derecha |
| 8 | Frontal derecha |

Las letras de cuadro empleadas en los nombres son:

| Letra | Acción |
|---|---|
| A | Idle |
| B | Move |
| C | Walk |
| D | Run |
| E | Attack |
| F | Pain |
| G–L | Muerte, etapas 1–6 |

Ejemplo: `RULOE3.png` es el ataque de Rulo visto desde la izquierda. `RULOJ0.png` es la cuarta etapa de su muerte y sirve para todas las direcciones.

### Por qué no 128×128 o 512×512

- **128×128:** obligaría a reducir demasiado la figura o cortaría armas y poses amplias. También degradaría rasgos raciales, armaduras y lectura de silueta.
- **512×512:** cuadruplica los píxeles de cada cuadro frente a 256×256. En 216 cuadros aumentaría de forma importante el uso de memoria sin aportar una mejora proporcional a la distancia normal de cámara.

## 4. Hojas completas: 1536×2304 px

Cada hoja de personaje contiene seis columnas y nueve filas:

- columnas 1–6: `idle`, `move`, `walk`, `run`, `attack` y `pain`;
- filas 1–8: las ocho direcciones;
- fila 9: seis etapas de muerte.

El cálculo es:

`6 × 256 = 1536 px` de ancho y `9 × 256 = 2304 px` de alto.

Estas hojas sirven como atlas maestro para inspección, conservación y recorte. El paquete `graphics` incluye también los 54 PNG individuales por personaje, ya nombrados para integración. Salvo que se defina expresamente un sistema de atlas, GZDoom debe usar esos cuadros individuales y no la hoja completa como un único sprite.

## 5. Texturas de alcantarillas y escenario

Las texturas del mundo no deben forzarse automáticamente a 128×128 o 256×256. Su tamaño depende del módulo y del área que representan. En el paquete existen piezas nativas como 64×64, 64×128, 128×128 y 256×256.

- Una pared, piso o techo repetible debe llenar el lienzo hasta sus bordes para cerrar la repetición sin costuras.
- Una puerta, rejilla, tubería o elemento móvil debe conservarse como pieza separada si requiere animación, colisión o desplazamiento propio.
- La resolución se elige según la densidad visual del escenario, no según el tamaño de los iconos del inventario.
- No deben agregarse márgenes transparentes a una textura que deba repetirse sobre geometría.

En las alcantarillas, mantener módulos de potencia de dos ayuda a combinar paredes, pisos, bordes y piezas de 64/128/256 px sin introducir escalas fraccionarias ni costuras visibles.

## 6. Interfaz y HUD

Los componentes de interfaz conservan sus dimensiones nativas porque responden a funciones distintas: barras, extremos, paneles, botones, retratos y fondos. No deben normalizarse todos a 128×128.

- Los iconos se insertan dentro del espacio que les asigne la interfaz.
- Los paneles y marcos se escalan mediante anclajes o segmentos, no estirando indiscriminadamente toda la imagen.
- Los fondos de pantalla de 1920×1080 se usan como composiciones completas, no como texturas del mundo.
- Los retratos, cursores y componentes pequeños mantienen el tamaño previsto por su definición de HUD.

## 7. Reglas de integración

1. Conservar los nombres y las rutas del paquete `graphics`; así pueden reemplazarse copiando y pegando.
2. Mantener PNG con canal alfa real. El damero nunca debe estar horneado dentro de la imagen.
3. No recortar cada cuadro de personaje a su caja mínima: se perdería el punto de apoyo común y la animación saltaría.
4. No agrandar un sprite pequeño para rellenar el lienzo. El tamaño físico se ajusta en la definición del actor o del HUD.
5. No estirar iconos ni personajes con proporciones distintas en X e Y.
6. Revisar siempre cabeza, pies y extremos de armas o efectos antes de exportar.
7. Mantener una versión maestra y generar reducciones desde ella; evitar ediciones generativas acumulativas que degraden el detalle.

## Criterio final

Los tamaños elegidos equilibran tres objetivos: legibilidad de la estética del proyecto, margen suficiente para animación y equipo, y un consumo razonable de memoria. La regla práctica es **128×128 para objetos de interfaz**, **256×256 por cuadro de actor** y **tamaño modular nativo para texturas y componentes de HUD**.

## 8. Integración concreta en V4.29.0r

La auditoría de integración aprobó los 137 iconos recompuestos y los 216
cuadros de Rulo, Ronnie, Argento y Caella. El informe del paquete enumera 39
iconos como su última corrección, pero esa cifra es un delta contra un paquete
artístico anterior que nunca había entrado al runtime. Frente al proyecto,
los 137 maestros son reemplazos. El runtime aplica estas adaptaciones sin
modificar sus píxeles:

- Los cuadros individuales se almacenan en `sprites/caelum/<personaje>`; las
  hojas maestras de 1536×2304 no entran en el PK3.
- Los prefijos de Ronnie y Argento se adaptan a los namespaces existentes
  `RONI` y `ARGO`. Rulo y Caella conservan `RULO` y `CAEL`.
- `TEXTURES` fija `Offset 128, 244` para 215 cuadros. La alineación no depende
  de metadata generada por SLADE ni de recortar el lienzo.
- `RONNA8` es la única excepción encontrada en el paquete: su alfa visible
  termina en `y = 235`. En runtime se remapea como `RONIA8` y usa
  `Offset 128, 235`, de modo que los pies coinciden con el resto sin modificar
  ni recomprimir el PNG original.
- Rulo usa `Scale 0.454545` para conservar 80 MU visuales; Ronnie, Argento y
  Caella usan `Scale 0.409091` para conservar los 72 MU visuales anteriores.
- El coste máximo sin comprimir de los 216 lienzos RGBA es aproximadamente
  54 MiB y las texturas se comparten entre todas las instancias; no se duplica
  una copia por NPC. El conjunto PNG integrado ocupa aproximadamente 11 MiB.
- Los `STF*` de preservación y cualquier recurso heredado de Doom quedan fuera
  de la integración. También se excluyen las hojas de revisión y las piezas de
  alcantarilla/Domingo que aún no tienen consumidores. Entran 353 PNG: 137
  iconos y 216 cuadros de actores.

## 9. Fuente gráfica única y Domingo en V4.29.0s

Los iconos recompuestos de `graphics/caelum/icons` son desde esta versión la
fuente canónica para dos consumidores: la interfaz usa su resolución completa
y los actores recogibles usan alias `TEXTURES` con origen inferior y escala
de mundo. No deben copiarse nuevamente a los antiguos directorios de
`sprites/caelum/{armor,weapons,materials,...}`. Esas copias históricas quedan
excluidas del PK3 para impedir que un nombre automático o una ruta antigua
vuelva a mostrar arte desactualizado y para no cargar dos veces los mismos
píxeles.

Domingo usa 39 cuadros individuales de 256×256: 16 direccionales para reposo y
movimiento, 15 frontales para los dos ataques y ocho etapas de muerte. Todos
usan `Offset 128, 244` y `Scale 0.409091`, equivalente a unos 72 MU de altura
visible. El conjunto se asigna al actor del jugador en tercera persona; no
reemplaza por sí mismo las manos o armas dibujadas en primera persona. Al
agacharse se reutiliza la misma apariencia comprimida y no el sprite PLYC
heredado de Doom.

## 10. Personajes folclóricos de V4.29.0aq

Palomo y Mandinga conservan lienzos de 256×256, pero sus figuras visibles son
mayores que los maestros humanos anteriores: aproximadamente 235 y 226 px.
Zupay usa 416×416 y ocupa 384 px visibles. Aplicar la antigua escala 0,409091
los sobredimensionaría; por eso los tres comparten `Scale 0.3125`. El resultado
es aproximadamente 73,4 MU para Palomo, 70,6 MU para Mandinga y exactamente
120 MU para Zupay, manteniendo su relación declarada de 3 m frente a 1,8 m.

`TEXTURES` fija pivotes constantes por personaje para evitar vibración entre
poses: Palomo `(128,246)`, Mandinga `(128,248)` y Zupay `(208,400)`. Los atlas
no entran al PK3. Los prefijos `PALM`, `PLLF`, `PLAG`, `PLJY`, `PLSP`, `PLSD`,
`PLTH`, `MNDG` y `ZUPY` separan las familias
sin agotar las letras de cuadro de un único sprite.

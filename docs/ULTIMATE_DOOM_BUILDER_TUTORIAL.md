# Ultimate Doom Builder para Caelum Argenteum

Esta guía enseña un flujo seguro para crear mapas propios y, en particular,
edificios con planta baja, primer piso y sótano. Está pensada para
**Ultimate Doom Builder**, mapas **GZDoom: Doom 2 (UDMF)** y la versión de motor
objetivo de Caelum, **GZDoom 4.14.2**.

La idea central es simple: primero se construye y valida una planta; después se
añade una sola capa vertical; recién entonces se duplican módulos o se agregan
puertas. Un mapa 3D complejo sigue siendo viable, pero necesita separar la
geometría jugable de sus sectores de control.

## 1. Preparación del editor

1. Descarga Ultimate Doom Builder desde su repositorio oficial o sus compilaciones
   enlazadas. En Windows requiere .NET Framework 4.7.2 y una GPU con OpenGL 3.2.
2. Conserva una copia de trabajo del proyecto. Nunca edites
   `build/caelum_argenteum_dev.pk3`: el constructor lo reemplaza.
3. Abre `src/maps/MAP01.wad` o crea un WAD nuevo.
4. Elige la configuración **GZDoom: Doom 2 (UDMF)**. No uses Doom, Boom ni
   Hexen Format para los mapas de Caelum.
5. En **Game Configurations / Resources**, añade como recurso de tipo
   **Directory** la carpeta `src`. UDB admite una carpeta con estructura PK3;
   así verá `TEXTURES`, actores, flats, sprites y texturas del proyecto sin
   duplicarlos dentro del WAD del mapa.
6. Configura GZDoom 4.14.2 como ejecutable de prueba y selecciona tu IWAD legal
   de Doom II o Freedoom 2.
7. Guarda el mapa antes de probar. El mapa fuente debe seguir dentro de
   `src/maps/`.

Si las texturas de Caelum aparecen como desconocidas, revisa primero que el
recurso sea exactamente la carpeta `src`, no `src/maps` ni el PK3 construido.

## 2. Tutorial 1 — una habitación limpia

Objetivo: crear una habitación funcional sin sectores residuales.

1. Crea un mapa de práctica, por ejemplo `MAP90`.
2. Ajusta la cuadrícula a 16 MU.
3. Desde un modo 2D, pulsa `Ctrl+D` para entrar en **Draw Geometry Mode**.
4. Dibuja un rectángulo de `512×512` MU y ciérralo sobre el primer vértice.
   `Enter` acepta el dibujo; `Esc` lo descarta.
5. Selecciona el sector interior. Usa suelo `0`, techo `128`, luz `176` y una
   textura de piso y techo conocidas.
6. Inserta un **Player 1 Start** dentro.
7. Pulsa `W` para entrar en **Visual Mode**. Allí:
   - clic derecho edita el objeto apuntado;
   - `Ctrl+clic derecho` abre el selector de texturas;
   - `A` alinea horizontalmente la textura vecina;
   - `Shift+A` la alinea verticalmente.
8. Ejecuta el análisis con `F4`. Corrige toda línea sin sector, sector sin
   cerrar, sidedef faltante o textura desconocida antes de probar.
9. Prueba el mapa desde el botón **Test Map** del editor.

No añadas puertas todavía. Primero comprueba cuatro cosas: puedes caminar por
todo el suelo, no atraviesas paredes, no hay huecos visuales y el automapa
muestra un contorno cerrado.

## 3. Tutorial 2 — habitación con paredes gruesas

Objetivo: aprender el módulo que usaremos en la mansión.

1. Parte de la habitación anterior.
2. Dibuja un segundo rectángulo interior separado 8 o 16 MU del contorno.
3. El anillo resultante es la pared; el rectángulo interior es la habitación.
4. Mantén un único sector interior. No cortes todavía umbrales, ventanas ni
   divisores.
5. En modo Linedefs, comprueba que cada línea bilateral tenga frente y reverso.
6. En Visual Mode, inspecciona las dos caras de cada pared.
7. Ejecuta `F4`, guarda, prueba y vuelve a abrir el WAD. La reapertura detecta
   problemas que una edición todavía no reconstruida puede ocultar.

Un contorno puede estar cerrado y aun así pertenecer al lado equivocado de sus
líneas. En UDB, las pequeñas marcas de frente deben mirar al sector que
realmente ocupan. Si generas geometría mediante un script, recorre el contorno
en sentido horario para dejar el interior en el lado derecho/frontal, o invierte
simultáneamente la línea y sus sidedefs. Nunca inviertas sólo los vértices.

Éste es el patrón robusto: **dos contornos, un anillo y un interior**. El parche
4.29.0h normaliza así las habitaciones centrales de MAP01.

## 4. Tutorial 3 — primer piso con un 3D floor

El formato Doom tradicional proyecta sectores en vertical. Para caminar sobre
una planta y también debajo de ella, GZDoom añade **3D floors**. Un 3D floor
relaciona:

- un **sector objetivo**, donde aparecerá la losa;
- un **sector de control** fuera del área jugable;
- una linedef `Sector_Set3dFloor` (especial 160) que conecta ambos mediante un
  tag.

Ejercicio:

1. Haz una copia del mapa de práctica.
2. Asigna un tag único, por ejemplo `700`, al sector interior objetivo.
3. Muy lejos del área jugable dibuja un pequeño sector de control.
4. Pon su suelo en `128` y su techo en `136`. Esos valores definen la cara
   inferior y superior de una losa de 8 MU.
5. En una línea del control asigna `Sector_Set3dFloor`:
   - `arg0`: `700`;
   - tipo: sólido;
   - alpha: `255`.
6. Usa en el control las texturas que deberán verse arriba, abajo y en el
   canto de la losa.
7. En Visual Mode, comprueba la losa desde abajo y desde arriba.
8. Añade una escalera real por sectores o coloca temporalmente dos Player Starts
   para probar ambas alturas.

No coloques dos 3D floors sólidos ocupando el mismo rango de altura en el mismo
sector objetivo. Una superficie invisible pero sólida suele significar un tag
equivocado, controles superpuestos o un sector objetivo cortado de forma
inconsistente.

## 5. Tutorial 4 — paredes y techo del primer piso

La losa no crea por sí sola paredes superiores.

1. Conserva el sector interior con la losa `128–136`.
2. Usa un tag distinto para el anillo de pared, por ejemplo `701`.
3. Crea un control sólido `136–256` que apunte sólo al anillo `701`.
4. Si quieres un techo/azotea caminable, crea otro control `256–264` que apunte
   al interior y, cuando corresponda, al anillo.
5. Mantén separados los propósitos:
   - losa: caminar arriba y debajo;
   - pared: bloquear lateralmente el primer piso;
   - techo: cerrar o permitir caminar sobre la estructura.
6. Prueba desde cinco posiciones: planta baja, debajo de la losa, primer piso,
   exterior a la altura del primer piso y azotea.

Para un sótano puedes invertir el planteo: deja el terreno principal en `0`,
excava sectores con piso negativo y usa escaleras o ascensores. Si necesitas
que un espacio se superponga horizontalmente con otro, los 3D floors siguen
siendo la primera opción. Los portales son útiles para casos especiales, pero
añaden otra capa de correspondencia y no deben ser la base del primer edificio.

## 6. Tutorial 5 — puertas y divisores sin romper la base

Sólo después de aprobar la habitación cerrada:

1. Haz una copia de seguridad del WAD.
2. Añade una única pared divisoria de 8 o 16 MU.
3. Prueba ambos lados antes de abrir un hueco.
4. Corta un vano rectangular con medidas exactas; evita vértices a menos de
   1 MU o segmentos mínimos accidentales.
5. Prueba el vano vacío.
6. Recién entonces añade la puerta, su TID/tag y su acción.
7. Confirma que la hoja se desplaza paralela a la pared y que su bloqueador
   coincide con la imagen visible.

Una puerta no debe ser también el parche de una losa. Su sector y sus tags se
usan para la puerta; las superficies continuas pertenecen a los controles de
la planta.

## 7. Tutorial 6 — módulo repetible de edificio

Para una mansión grande, construye por módulos:

1. Una habitación cerrada y validada.
2. Su losa y pared superior con tags exclusivos.
3. Una escalera o conexión validada.
4. Una puerta validada.
5. Recién entonces repite el módulo.

En agosto de 2026 existe un problema abierto de UDB: duplicar una selección con
varios 3D floors y pendientes puede colapsar tags, dañar la copia y también el
original, incluso fuera del historial de deshacer. Por eso, para Caelum:

- no dupliques bloques complejos con controles 3D y slopes juntos;
- copia primero la geometría plana;
- crea tags y controles nuevos para la copia;
- guarda, cierra y reabre antes de continuar;
- conserva una versión anterior del WAD.

## 8. Lista de control antes de entregar un mapa

- Configuración GZDoom Doom 2 UDMF.
- `namespace = "ZDoom"` en TEXTMAP.
- Un Player 1 Start válido.
- Ninguna línea de longitud cero.
- Toda linedef tiene front sidedef.
- `sideback` y la marca `two-sided` concuerdan.
- Ningún sidedef huérfano.
- Todos los sectores están cerrados.
- Tags de 3D floors únicos y documentados.
- Ningún control sólido duplicado sobre la misma altura.
- Coordenadas X/Y dentro de `-32768..32768`.
- Prueba visual arriba, abajo, dentro y fuera.
- Prueba de colisión caminando y saltando por bordes y umbrales.
- `F4` sin errores estructurales relevantes.
- WAD reabierto con éxito.
- PK3 reconstruido con `python tools/build_pk3.py src build/caelum_argenteum_dev.pk3`.

## Referencias

- [Repositorio y requisitos de Ultimate Doom Builder](https://github.com/UltimateDoomBuilder/UltimateDoomBuilder)
- [Manual oficial: Draw Geometry Mode](https://github.com/UltimateDoomBuilder/UltimateDoomBuilder/blob/master/Help/e_drawgeometry.html)
- [Manual oficial: Visual Mode](https://github.com/UltimateDoomBuilder/UltimateDoomBuilder/blob/master/Help/e_visual.html)
- [Manual oficial: Map Analysis Mode](https://github.com/UltimateDoomBuilder/UltimateDoomBuilder/blob/master/Help/e_mapanalysis.html)
- [Especificación UDMF de GZDoom](https://github.com/ZDoom/gzdoom/blob/master/specs/udmf_zdoom.txt)
- [Guía progresiva de modding GZDoom/UZDoom](https://github.com/dileepvr/gzdoom_modding_101)
- [Problema abierto al duplicar 3D floors complejos](https://github.com/UltimateDoomBuilder/UltimateDoomBuilder/issues/1363)

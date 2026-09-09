# Iconos de equipo — importación V4.33.0d

Fuente autoral: `Caelum_Argenteum_tiers_2_3_argentinos_REHECHOS.zip`.

Se incorporan sus 99 PNG sin modificar sus bytes, dimensiones, proporciones,
transparencia ni nombres: 49 variantes T2, 49 variantes T3 y
`ca_giant_gauntlets.png` corregido. Incluye armas, armaduras, guantes, botas,
cascos, escudos, amuletos y sellos.

Destino: `src/graphics/caelum/icons/`, preservando `jewelry/`. El resolver de
iconos existente selecciona `_t2` y `_t3`; los archivos sustituyen sus versiones
anteriores en el inventario, equipo, comercio y menús que usan ese resolver.
No son cuadros del rig de manos/espada de primera persona.

Cada PNG es RGBA 128×128 y tiene alfa transparente y contenido visible. La
auditoría compara los 99 archivos contra los bytes del adjunto y contra el
runtime completo. El manifiesto y las instrucciones de autor se conservan en
`art_source/tiers_2_3_rehechos_4_33_0d/`.

Los adornos T2/T3 argentinos y la pareja corregida de guanteletes reemplazan
los iconos anteriores. Estadísticas, valores, recetas, pesos y mecánicas no
dependen de esta importación gráfica.

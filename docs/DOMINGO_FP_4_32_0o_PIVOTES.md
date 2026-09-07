# V4.32.0o — corrección del cuadro con dos manos

## Diagnóstico

La captura del autor corresponde a un cuadro intermedio del ataque: `RHND`
muestra el antebrazo y la base del puño, mientras `RFNG` aporta el pulgar y los
dedos que deben quedar delante del mango. No son dos manos diseñadas; son dos
capas complementarias de la misma mano que dejaron de coincidir al rotar.

V4.32.0n convirtió puntos del lienzo PNG completo a porcentajes. En GZDoom, el
pivote porcentual se resuelve sobre la caja visible de la textura. Las tres
cajas A son diferentes:

| Capa | Caja inclusiva | Tamaño visible | Pivote V4.32.0n resultante |
| ---: | ---: | ---: | ---: |
| `RHND` | (147,128)–(479,239) | 333×112 | (95.225,137.2) |
| `DSWD` | (168,0)–(294,178) | 127×179 | (56.64375,84.57) |
| `RFNG` | (148,92)–(210,151) | 63×60 | (18.7125,100.2) |

Estos valores ya incluyen `grAb` y la diferencia de offset de la espada. La
separación entre los tres pivotes explica por qué la duplicación sólo se hacía
evidente cuando aumentaba el ángulo.

## Corrección

La espada mantiene `(0.55625,0.83)`, porque su trayectoria y su ángulo ya
estaban aprobados. Sólo se recalculan mano y dedos contra las cajas visibles:

| Capa | Pivote V4.32.0o | Resultado de pantalla |
| ---: | ---: | ---: |
| `RHND` | (0.2091403904,0.2550892857) | (56.64375,84.57) |
| `DSWD` | (0.55625,0.83) | (56.64375,84.57) |
| `RFNG` | (1.0895833333,0.4095) | (56.64375,84.57) |

La mano y los dedos continúan usando `rotación_espada - 18°`. Al compartir el
pivote efectivo de la hoja, las tres capas reciben la misma variación angular
sin apartarse del mango.

## Alcance y cierre

No cambia ningún PNG, offset, ángulo, tic ni punto de la trayectoria. Tampoco
cambian Block, escudo, daño, Aire, durabilidad, equipo, HUD, persistencia,
Palomo, Caja Mágica, economía, crafting, diálogos ni mapas.

Para cerrar V4.32 y avanzar a V4.33 sólo se requiere la prueba focalizada de
`PRUEBAS_4_32_0o.txt`: comprobar todos los cuadros del ataque sin doble mano,
el pulgar delante del mango, diez ataques sin deriva y las regresiones breves
de reposo/Block/equipo. Todo lo ya aceptado permanece cerrado.

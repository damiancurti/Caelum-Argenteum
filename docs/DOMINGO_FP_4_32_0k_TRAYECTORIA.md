# Registro de encuadre y trayectoria — Domingo FP V4.32.0k

## Corrección de interpretación

La primera captura confirma que V4.32.0j movió sólo la mano izquierda. La
aclaración autoral exige mover también el escudo normal al mismo destino. Por
eso las capas `DSHD` y `LHND` comparten (82,45) fuera de Block. La pose
sostenida de Block conserva (160,100), escala, perspectiva y arte aprobados.

La segunda captura distingue dos objetivos derechos. Palma y dedos usan
(282,32). La espada usa (280,4): frente a V4.32.0j, el mango se desplaza 36
píxeles de referencia a la izquierda y aproximadamente 130 hacia arriba, hasta
su contorno azul. La diferencia espada–mano permanece constante en (-2,-28)
durante todo el golpe.

## Muestreo de la curva negra

La pose A dura ocho tics. Los cinco primeros puntos aproximan el recorrido
negro y mantienen el cambio angular solicitado:

| Punto | Mano/dedos | Espada | Rotación del motor |
| ---: | ---: | ---: | ---: |
| 1 | (300,15) | (298,-13) | 21° |
| 2 — ápice | (318,-4) | (316,-32) | 24° |
| 3 | (287,-1) | (285,-29) | 31° |
| 4 | (236,11) | (234,-17) | 38° |
| 5 — impacto | (201,21) | (199,-7) | 43° |

En la referencia 1920×1080, el anclaje de mano aproxima (1658,713),
(1739,610), (1599,626), (1370,691) y (1212,745), respectivamente.

## Regreso directo

Después del impacto, la mano pasa por (228,25), (255,28) y (275,31), antes de
restablecer (282,32). Esos puntos son colineales, con tolerancia de redondeo,
entre (201,21) y el reposo. La hoja usa los equivalentes (226,-3), (253,0) y
(273,3), y su rotación desciende 39°→31°→24°→18°.

El regreso no invierte ni repite la curva de salida. Los extremos visuales
siguen siendo aproximadamente 79° en reposo y 104° al impactar. No cambian los
sprites, `grAb`, tiempos totales, capas, daño ni demás sistemas jugables.

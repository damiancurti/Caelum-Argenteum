# Registro artístico — Domingo FP V4.32.0j

## Corrección solicitada

La referencia del autor separa dos cambios. El escudo aprobado en V4.32.0i se
conserva byte por byte. En la pose normal, sólo la mano izquierda baja hacia la
marca azul inferior izquierda y el conjunto modular mano derecha–espada–dedos
se traslada hacia la marca azul inferior derecha. En Block, la mano horizontal
visible estaba invertida.

## Mano de Block

La edición exploratoria utilizó la herramienta integrada en modo
`precise-object-edit` para comprobar la lectura anatómica: el puño debía
conservar su función de agarre y el antebrazo debía entrar desde el lado
opuesto. La variante generada fue discarded porque reinterpretó materiales y
no conservó los píxeles originales.

La integración final usa una transformación determinista: `RHNDH0`,
`RHNDI0`, `DSWDH0`, `DSWDI0`, `RFNGH0` y `RFNGI0` son el exact horizontal mirror
de sus cuadros V4.32.0f. Se reflejan las tres capas del conjunto, no sólo
la palma, para mantener registrado el contacto entre mano, transición de
espada y dedos. El lienzo sigue siendo RGBA 320×200 y `grAb (160,32)`.

Las copias sin `grAb` utilizadas para auditar la transformación están en
`art_source/domingo_fp_4_32_0j/`. El prompt exploratorio completo se conserva
en `IMAGEGEN_PROMPTS.txt`.

## Posiciones de motor

| Estado | Escudo | Mano izquierda | Conjunto derecho |
| --- | ---: | ---: | ---: |
| Reposo/selección | (105,0) | (82,45) | (288,28) |
| Ataque: preparación | (105,0) | (82,45) | (302,36) |
| Ataque: extensión | (105,0) | (82,45) | (260,10) |
| Ataque: recuperación | (105,0) | (82,45) | (276,21) |
| Block sostenido | (160,100) | (160,100) | (160,0) |

Los ángulos 18°/24°/43°/31°, el pivote `(0.55625, 0.83)`, los tiempos y todo
el comportamiento jugable permanecen sin cambios.

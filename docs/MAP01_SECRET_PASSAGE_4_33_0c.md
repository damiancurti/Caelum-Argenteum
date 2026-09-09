# MAP01 — residentes y pasadizo secreto V4.33.0c

## Coordenadas autoritativas

| Elemento | X | Y | Z | Ángulo | Referencia |
| --- | ---: | ---: | ---: | ---: | --- |
| Argento | 1040 | -378 | 136 | 90° | sector aproximado 350 |
| Caella | -290 | -378 | 136 | 90° | sector aproximado 189 |
| Rulo | -290 | 378 | 136 | 270° | sector aproximado 212 |
| Ronnie | 1036 | 378 | 136 | 270° | sector aproximado 351 |
| Pared falsa de entrada | 1842 | -360 | 0 | 90° | sector aproximado 90 |
| Segunda pared falsa | 1944 | -87 | 0 | 180° | sector aproximado 91 |
| Pared de fondo | 1842 | 366 | 0 | 270° | sector aproximado 92 |
| Ascensor | 1917 | 316 | 0 | 90° | sector aproximado 92 |

La asignación de las tres coordenadas occidentales sigue el orden proporcionado
por el autor: Caella, Rulo y Ronnie.

## Colisión de residentes

Las cuatro instancias de historia usan `args[0]=1`. Son sólidas, tangibles,
amistosas e invulnerables. No buscan blancos. Conservan posición y ángulo de
aparición como ancla y sólo comienzan a regresar cuando su distancia horizontal
al origen llega a 500 MU; desplazamientos menores se toleran. El regreso usa la
velocidad de carrera, mantiene la animación correspondiente y termina en el
punto/ángulo original.

## Geometría y enlace vertical

Las paredes falsas emplean la misma textura interior `CMIN01`, visible por ambos
lados mediante dos WALLSPRITE separados 0.25 MU. Ninguna cara entra en el
blockmap, por lo que se atraviesan sin una línea invisible residual. La pared
del fondo sí usa la pared finita sólida aprobada.

El ascensor mide 84×88 MU y ocupa `x=1875..1959`, `y=272..360`: permanece
dentro de los límites comprobados del sector 92 y deja libre la pared de fondo.
El personaje XL máximo tiene radio 21.33 MU (42.67 de diámetro), por lo que la
cabina dispone de margen en ambos ejes. Pisar la plataforma conecta con la
cabina inferior sin cambiar de mapa ni reconstruir el personaje; la plataforma
inferior permite regresar y ambos destinos quedan fuera del volumen opuesto
para evitar rebotes.

## Cueva de materiales

La cueva es un recinto UDMF cerrado de 1000×800 MU, a cota de piso -256. Incluye:

- tres Espinillos jóvenes renovables;
- vetas tutoriales de hierro, carbón, cobre y estaño;
- una hachuela T1 única, cuyo talle se resuelve al recogerla según el tamaño del
  personaje.

Fire de la hachuela conserva daño cortante y tala los árboles. AltFire conserva
el daño romo aprobado y extrae las cuatro vetas tutoriales. No se cambian las
reglas de las vetas comunes, que siguen requiriendo daño perforante.

La disposición está lista para las fases de Caella/Ronnie, pero V4.33.0c no
abre el pasadizo mediante misión ni registra materiales reunidos. No completa objetivos:
esas conexiones se implementarán en su subparche narrativo.

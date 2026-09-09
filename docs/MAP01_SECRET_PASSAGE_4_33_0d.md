# MAP01 — pasadizo y ascensor físico V4.33.0d

## Contrato vigente

La devolución del autor sustituye el prototipo V4.33.0c. La cueva ya no ocupa
una habitación remota: se excava bajo el terreno de MAP01 y se conecta mediante
un túnel al pozo del ascensor.

| Elemento | Posición o extensión | Comportamiento |
| --- | --- | --- |
| Falsa fachada | X=1842, Y=-383..383, Z=0..128 | Paralela al muro oriental X=1961 |
| Entrada secreta | X=1842, Y=-383..-287 | Misma textura; 96 MU atravesables |
| Fachada restante | X=1842, Y=-287..383 | Midtexture nativa sólida a nivel del suelo |
| Segundo tabique | Y=-87, X=1842..1961 | Misma textura; atravesable |
| Pasillo oculto | X=1842..1961 | Ancho libre 119 MU |
| Ascensor | Centro (1917,316); X=1875..1959, Y=272..360 | 84×88 MU |
| Recorrido vertical | Z=0 a Z=-384 | Piso móvil nativo, 2 MU/tic |
| Túnel inferior | X=1875..1959, Y=360..480 | Continuo; piso -384, techo -64 |
| Cueva | X=975..1999, Y=480..1280 | Contorno 1024×800 MU, esquinas recortadas |

Los extremos de la fachada se prolongan hasta los muros existentes a Y=±383
para que no queden huecos por los costados. Las texturas se repiten con escala
normal en vez de estirar un sprite de pared sobre todo el largo.

## Funcionamiento del ascensor

1. Entrar completamente sobre la plataforma de madera inicia el descenso.
2. El piso lleva físicamente al personaje hasta -384; X/Y y su orientación
   no se fuerzan ni se reemplaza al jugador.
3. Abajo espera 175 tics (cinco segundos) y vuelve al nivel de la mansión.
4. Para regresar desde la cueva, mirar la cara de la plataforma desde el túnel
   inferior y pulsar **Usar**. Esperar a que baje, subir y dejar que regrese.
5. Si se permanece sobre ella durante todo el ciclo, se desciende y asciende
   sin salir. Hay que salir y volver a entrar, o usar una cara, para otro ciclo.

`Plat_DownWaitUpStayLip` controla movimiento, espera, colisión y guardado. El
actor de activación sólo comprueba que el radio completo del jugador quepa
en la plataforma. Las cuatro caras permiten la llamada nativa repetible.

## Recursos y herramienta

| Recurso | Clase normal / posición | Ataque de la espada |
| --- | --- | --- |
| Árboles jóvenes | (1170,680), (1500,845), (1740,1040) | Fire, cortante |
| Cobre bruto | CaelumVeinCopper2, (1860,1150) | AltFire, punzante |
| Estaño bruto | CaelumVeinTin2, (1100,1100) | AltFire, punzante |
| Espada T1 | CaelumM01SwordPickup, (1860,575) | Se recoge y equipa normalmente |

Todos están sobre el piso de la cueva, Z=-384. La espada ajusta su talle al
personaje al recogerla. Las vetas son las mismas clases del catálogo mundial
y tienen sus registros en MODELDEF; se elimina la excepción roma y las cuatro
subclases invisibles de 0c. La cueva no contiene hachuela, hierro ni carbón.

## Conservación de la mansión

La excavación conserva la cota, textura y control de los pisos superiores:
sectores derivados mantienen los tags previos mediante `moreids`; losas entre
-64 y 0 reconstruyen el suelo original. Las barandas nativas inferiores
ancladas al suelo compensan los 384 MU de excavación con su escala de textura
existente. El pozo deja libre únicamente la huella de la plataforma.

Argento, Caella, Rulo y Ronnie conservan las coordenadas aprobadas. Ellos y
Palomo regresan corriendo al alejarse **100 MU** de su origen. El resto del
comportamiento físico aceptado se conserva.

## Validación y límite narrativo

GZDoom 4.14.2 ejecutó un ciclo completo, con jugador transportado por el suelo,
y el paso caminando desde el túnel hasta la cueva. La revisión visual del
motor comprobó la veta de cobre. La validación manual del autor se concentra
en los accesos, la llamada inferior, el tamaño XL, guardar/cargar en tránsito
y extraer madera/cobre/estaño con la espada.

Esta revisión no completa objetivos de Argento, Caella o Ronnie. Esas fases
continúan reservadas hasta implementar sus diálogos y condiciones de misión.

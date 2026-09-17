# Caelum Argenteum — First-person art pack v1

Original modular hand and weapon art for the project's nineteenth-century
Argentine dark fantasy style. Target engine: GZDoom 4.14.2 on Windows 11.

The pack provides 20 weapon families in three equipment tiers: 93 weapon/pose
PNGs, eight reusable hand layers, and 93 virtual hand-and-weapon composites.
Runtime PNGs are 320×200 RGBA with grAb offsets (160,32). Registered 640×400
exports, unregistered cutouts, accepted source atlases and prompts are kept in
`assets/first_person_v1` for editing.

Melee weapons, the staff and the statuette share a closed sword-style grip.
Bows are held across the view; the bell uses the horizontal right-hand grip.
The book rests entirely above an upturned palm. The carbine uses an original
wood-and-steel design with a centered first-person sightline. No Doom weapon
images are included. The giant gauntlets already contain the player's fists.

This is an art and integration package. The current gameplay code is not
replaced. Copying its PNGs makes the resources available but does not attach
them to the equipped-weapon selectors. Spanish installation instructions,
state mappings, layer order and pivot data are included. Existing sword/shield
integration remains the accepted reference; its DSWD/RHND/RFNG names are not
overwritten by this pack.

Start with `INSTALACION_Y_PRUEBAS.txt`. Open `VISTA_PREVIA.html` offline to
inspect tiers, poses, layers, alpha and the slow melee movement preview.
Source artwork was generated with the built-in image tool using approved
project assets. Export processing crops atlases, sizes and registers layers,
writes PNG offsets and builds previews. No automatic patch installer is used.

Asset validation is recorded in `VALIDACION.json`. Engine compilation and
in-game acceptance remain pending; this package does not claim a tested
gameplay integration.

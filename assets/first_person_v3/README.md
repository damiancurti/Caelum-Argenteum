# First-person corrections — 4.36.0e

Native source of truth: `src/caelum/equipment/CaelumFirstPersonLayers.zs` and
`src/TEXTURES`. `SPRITES.json` records source-pixel crops, pivots and tips.

Fists reuse FH01A0, with native mirroring for the left side. Bow hands reuse
FH03A0/FH04A0/FH07A0; no new glove style is introduced. All original v1 PNG
bytes are preserved. New bow staves and arrow PNGs were made with the built-in
OpenAI image-generation tool, without pixel editing. Their source alpha is
preserved. Fully transparent RGB pixels may contain background colors, which
are ignored when composited using alpha.

Bow staves are three-column atlases, ordered T1 bronze/T2 silver/T3 gold.
Native frames crop one 512x1024 column. The grip is a common anchor across
ready, aim and release; aiming applies a small native flex. Two native string
segments follow the tips and nock. The separate arrow is shown only when the
real weapon state has a loaded arrow. Overlays 46–52 are cleared on hide or
family changes. Previous state labels retain their order for saved games.

Prompts and asset hashes are recorded beside this file. Rejected drafts are
not runtime dependencies. Reconstructed previews were inspected locally;
GZDoom compilation and in-game visual acceptance remain pending for 0e.

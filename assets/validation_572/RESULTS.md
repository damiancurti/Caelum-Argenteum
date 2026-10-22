# 5.7.2 / #405 - Land resources

Native GZDoom 4.14.2 checks cover exact extraction, fractional carry, hive
Use debouncing, sword harvesting, material drop/split/Box ownership, imports,
ordinary trade, old/current saves, hub travel and real MAP01/MAP03 placement.
The final selection has **168 PASS, zero FAIL in 15 runs**. report.json records
run labels, commands, environment and package identities. Project validation
passed; twenty generated files reproduced byte-for-byte, including all fourteen
volumetric models. All 16,454 final package members match their source bytes.
CA405-01 remains pending author acceptance, including the 3D presentation.

Exploratory failures are preserved: compile-01 override default argument,
compile-02 unsupported floor constant, compile-03 unregistered M081 sprite,
suite-01 reading a spawned actor before deferred initialization, travel-01
fixture-held pointers to unloaded map actors, and mapupgrade-01 missing new
ordinary EventHandler on a pre-feature save. The last required a production
StaticEventHandler fix; persistent IDs/reserves remain map-owned (CA-KP-013).
final-map03-reload sent its diagnostic before the restored player was available;
the runner rejected absent results. final-map03-reload2 waits for native startup
and verifies six remaining sources plus all seven issued IDs (10 PASS).

Presentation smoke check, MAP01 garden, Vulkan 1280x720/60-FPS cap, Ryzen 9
5950X / RTX 3070 Ti, ten seconds per build:

| Build | Mean callback FPS | p95 ms | p99 ms | Worst ms | Simulation tics/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| Prior runtime | 58.399 | 17.785 | 18.712 | 243.176 | 34.991 |
| 5.7.2 | 58.896 | 18.282 | 19.828 | 161.821 | 35.024 |

These short samples retain visible tail stalls; they do not establish smooth
60-FPS rendering or a performance improvement. Full raw callback samples are
preserved. No accepted visual feature was removed to improve a number.

The native room and command files are generated locally by prepare.py.
Run run_native.ps1 with a new label; it preserves logs and rejects overlapping
game sessions. No engine, IWAD, test WAD, PK3 or personal save is distributed.
Tests use background rendering, unpaused simulation and 5% audio. Frame
callback measurements are application observations, not OS presentation or
acceptance of mansion/sewer/siege performance. No retired stress case is used.

Provenance: fourteen deterministic original meshes with existing owned project
textures, listed in assets/generators/land_resource_models.json. UI thumbnails
reuse owned material icons. New ingredient recipes remain separate #471/#472.

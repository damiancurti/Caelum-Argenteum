# Caelum Argenteum — Event audio pack v1 (revision 1.4)

Historical audio-package record. The integration and test status below describes
the original delivery; subsequent integration is recorded in INTEGRACION_4_36_0c.txt.
For current checkout setup and outstanding author checks, use the root README.md
and pending_test.txt. Do not repeat this archived resource installation.

Six Ogg Vorbis files for five requested events, including an alternative ship
excerpt. This is an audio resource and integration package, not a complete game
patch. Reference source documentation: Caelum Argenteum 4.36.0a; target engine:
GZDoom 4.14.2 on Windows 11.

| Event | Excerpt in source | Output |
| --- | --- | --- |
| Lever activation | Full 0.154-second click | Mono, one shot |
| Carriage travel | 00:02–00:08 | Stereo, 6 seconds |
| Ship travel | 00:03–00:09 | Stereo, 6 seconds |
| Tarot capture | MAP01 00:30.358146–00:33.667042 | Stereo, 3.309 seconds |
| Rolling rock | 00:38.30–00:42.40, 0.30-second crossfade | Mono, 3.80-second loop |
| Optional ship opening excerpt | 00:00–00:06 | Stereo, 6 seconds |

Extract the ZIP and open `ESCUCHAR.html` to audition the clips locally.
Read `INSTALACION_Y_PRUEBAS.txt` for installation and event mapping.

The four external sources are public high-quality MP3 previews of the exact
Freesound items selected by the project author. All four source pages identify
them as CC0 1.0. The authenticated original WAV downloads were not obtained.
Edited 24-bit WAV masters, those MP3 sources and exact edit metadata are included
under `assets/audio_eventos_v1`. Converting an MP3 preview to WAV does not restore
the original recording quality.

The tarot excerpt comes from the existing project file `CA_MUS01.mp3` (metadata:
The Argentine Omen). The author requested the phrase around 00:30–00:33.
The excerpt is shifted 200 ms later than revision 1.3, to 00:30.358146–00:33.667042.
Its duration and 2 ms / 20 ms fades remain unchanged. The edit retains the
complete mix of the music; it is
not an isolated guitar stem. The full music track is not modified or duplicated.
Its original project rights remain applicable; this pack does not label it CC0.

Only new resources are supplied. The SNDINFO addition is a fragment under
`assets/audio_eventos_v1/integration`, so copying `src` cannot overwrite the
project's existing SNDINFO. Event calls still need to be connected in the current
game source. No installer, gameplay replacement or engine-tested claim is included.

`VALIDACION.json` records decoding, sample rate, channels, duration and peak checks.
Credits and source links are in `src/licenses/AUDIO_EVENTOS_V1_CREDITS.md`.

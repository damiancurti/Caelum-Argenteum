# Caelum Argenteum — issue #31 audio provenance

This file ships inside the PK3. It records the source-to-runtime mapping for
the author-selected pain sounds, the dialogue-opening cue and the three new map
music tracks integrated under issue #31. It does not claim rights that the
project has not verified.

## Music reassignment

| Runtime alias | Source local file | Assignment | Processing |
| --- | --- | --- | --- |
| `CA_MUS01` | Existing `music/CA_MUS01.mp3` | Story opening and reserved chapter intermissions | No re-encoding; existing rights and credits remain valid. |
| `CA_MUS02` | Existing `music/CA_MUS02.mp3` | New MAP01 background music | No re-encoding; existing rights and credits remain valid. |
| `CA_MUS03_SEWER` | `assets/audio_stock/music/Alcantarillado - Caelum Argenteum.wav` | MAP02 sewer background music | WAV converted to stereo 48 kHz Ogg Vorbis. |
| `CA_MUS04_PORT` | `assets/audio_stock/music/Puerto - Caelum Argenteum.wav` | MAP06 port background music | WAV converted to stereo 48 kHz Ogg Vorbis. |
| `CA_MUS05_COAST` | `assets/audio_stock/music/Costa - Caelum Argenteum.wav` | MAP07 coast background music | WAV converted to stereo 48 kHz Ogg Vorbis. |

The local MP3 files in `assets/audio_stock/music/`, the unused WAV tracks
`Ciudad`, `Cueva`, `Playa` and `Puerto Buenos Aires`, and the entire
`assets/audio_stock/sounds/` source set are preserved as stock. They are not
packaged as runtime audio and remain unbound.

## Author-created Suno music

The four selected local WAV files below were created by **Damián Curti using
Suno**. Their embedded provenance is retained:

| Local source | Runtime file | Suno ID | Created |
| --- | --- | --- | --- |
| `Alcantarillado - Caelum Argenteum.wav` | `music/CA_MUS03_SEWER.ogg` | `79d73700-abac-4a87-a4c1-a194bc3a3f1e` | 2026-09-24T20:08:55Z |
| `Puerto - Caelum Argenteum.wav` | `music/CA_MUS04_PORT.ogg` | `4affa571-af01-4e8d-b4c1-674120847ae7` | 2026-09-24T20:00:01Z |
| `Costa - Caelum Argenteum.wav` | `music/CA_MUS05_COAST.ogg` | `62f157f1-9f7f-4137-a4b3-4ea2b43a7ae8` | 2026-09-24T20:04:46Z |
| `A Single Short Dialogue-opening Sound For A Dark Fantasy Rpg Set In Nineteent.wav` | `sounds/caelum/ui/ca_dialogue_open.ogg` | `51197596-7b98-4f17-915e-cdf377bc6dd3` | 2026-09-24T20:33:37Z |

The existing MAP01/MAP02 tracks remain **The Argentine Omen** by `marjaja197`
(Suno), as recorded in `AUDIO_EVENTOS_V1_CREDITS.md`.

## Pain-state mapping

| Actor / voice profile | Runtime file | Verified credited creator | Source URL | Displayed terms |
| --- | --- | --- | --- | --- |
| Mandinga | `sounds/caelum/enemies/mandinga/ca_mandinga_pain.ogg` | **PhatPhrogStudio** | https://pixabay.com/sound-effects/horror-demon-voice-damage-grunt-503867/ | Pixabay asset 503867; displayed license/terms not recorded in the author's update. |
| Male human / male Caelith, Argento, Ronnie | `sounds/caelum/player/pain/ca_player_pain_male.ogg` | **Snaginneb** | https://dev.creazilla.com/media/audio/15427820/gruntsound | Author-supplied screenshot: Author Snaginneb, Source Freesound.org, Public Domain (CC0). Original Freesound URL not yet verified. |
| Female human / female Caelith, Caella | `sounds/caelum/player/pain/ca_player_pain_female.ogg` | **freesman** | https://directory.audio/es/efectos-de-sonido/gente/36688-mujer-gritos-de-dolor | Directory.audio asset 36688 displayed as CC0. |
| Bull | `sounds/caelum/enemies/bull/ca_bull_pain_01.ogg` through `ca_bull_pain_12.ogg` | **53439420** | https://pixabay.com/sound-effects/people-weird-bull-bellow-451598/ | Pixabay asset 451598; displayed account name retained for all variants. Displayed license/terms not recorded in the author's update. |
| Zupay | `sounds/caelum/enemies/zupay/ca_zupay_pain.ogg` | **Brorsan Beppe** | https://www.summerengine.com/asset-store/sfx-deep-monstrous-demon-boss-roar-433fab20 | Author-supplied screenshot: Creator Brorsan Beppe, License CC0, Generated via ElevenLabs sound_effects, source Summerengine. |

Rulo remains silent for combat pain; it is not assigned the human profile.

## Bull variant extraction

The bull source is one mono 44.1 kHz recording with multiple bellows. The
selected segments retain natural endings and are written as twelve independent
mono Ogg Vorbis files, normalized to -6 dBFS. The runtime alias
`caelum/enemies/bull_pain` selects one variant with the existing `$random`
mechanism; the full sequence is never played for one injury.

| Output | Source segment (seconds) |
| --- | --- |
| `ca_bull_pain_01.ogg` | 0.300–1.220 |
| `ca_bull_pain_02.ogg` | 2.720–3.410 |
| `ca_bull_pain_03.ogg` | 3.580–4.440 |
| `ca_bull_pain_04.ogg` | 5.430–6.270 |
| `ca_bull_pain_05.ogg` | 7.600–8.660 |
| `ca_bull_pain_06.ogg` | 9.660–11.210 |
| `ca_bull_pain_07.ogg` | 12.550–13.590 |
| `ca_bull_pain_08.ogg` | 15.230–16.350 |
| `ca_bull_pain_09.ogg` | 17.340–18.230 |
| `ca_bull_pain_10.ogg` | 20.300–21.190 |
| `ca_bull_pain_11.ogg` | 24.440–27.820 |
| `ca_bull_pain_12.ogg` | 28.730–29.740 |

## Processing and verification status

- Pain cues are spatial effects in mono, normalized to -6 dBFS and encoded as
  Ogg Vorbis without clipping.
- The dialogue-opening cue replaces the previous `ca_dialogue_open.ogg`
  content. It is the supplied stereo 48 kHz WAV, 134 400 samples (2.8 s), and
  remains the only `GameInfo.ChatSound` emitter with `$limit 1` and `$singular`.
- Music tracks are stereo 48 kHz Ogg Vorbis from the supplied WAV masters.
- The 2026-09-25 issue update records the verified credited names above from
  author-inspected source pages/screenshots. The project does not credit the
  hosting platforms or ElevenLabs as human creators; ElevenLabs is disclosed
  as the generation tool for the Zupay sound.
- The displayed CC0 labels are retained for Snaginneb, freesman and Brorsan
  Beppe. Pixabay asset-page license/usage terms for PhatPhrogStudio and
  `53439420` still need to be confirmed and recorded before final public
  redistribution.

## Existing credits

The previous audio credits remain in `AUDIO_CREDITS.md`,
`AUDIO_PACK_04_CREDITS.md`, `AUDIO_PACK_05_CREDITS.md` and
`AUDIO_EVENTOS_V1_CREDITS.md`.

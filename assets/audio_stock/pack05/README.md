# Audio Reserve — 05 Package

These 10 files passed the technical validation and have compatible licenses, but they do
not yet have an approved Caelum Argenteum event. They are saved outside `src/`, so
`build_dev.ps1` does not incorporate them into the game. They do not alter any current sound.

To approve one:

1. define the specific scene or event;
2. move it to a stable path under `src/sounds/caelum/`;
3. declare it with a logical name in `src/SNDINFO`;
4. test mixing, repetition, distance and coexistence with music/dialogue;
5. keep the credit included in `src/licenses/AUDIO_PACK_05_CREDITS.md`.

The two legally quarantined files of the original package were not copied.

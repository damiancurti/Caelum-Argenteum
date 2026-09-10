# Caelum Argenteum

An independent dark fantasy FPS-RPG inspired by nineteenth-century Argentina.
Author and game designer: **Damian Curti**. Development target: **GZDoom 4.14.2**
on Windows 11. The final game is intended to be independent of Doom assets.

**Current release: 4.33.0h.** Last accepted gameplay base: **4.33.0f**.
Documentation reviewed: 2026-09-10. All author NPC conversation tests passed.
0h corrects the reported 0g audio defects and cleans the complete supplied
project. The complete roadmap and folder audit are in [PROJECT.md](docs/PROJECT.md).

## Implemented

- Character creation, attributes, survival resources, inventory/equipment,
  crafting, repair/disassembly, physical currency and merchant infrastructure.
- Physical/ranged/magical combat, contextual Block/ADS, charged attacks and
  equipped-Seal Channel. Sword/hand/shield framing 4.32.0o remains accepted.
- MAP01 mansion, secret facade, native moving lift and resource cave.
- Prologue, Unknown Voice, Palomo and Argento's social task: recruit the three
  residents, persist results/failure alternatives, return at 3/3 to phase 35.
- 0h: one native harp phrase on dialogue opening and every next page; explicit
  title music looping; existing project menu/Quit/Exit sounds preserved.
- A single root Windows builder, source art and reusable generators in assets,
  five active documents and a hash-checked cleanup applicator with rollback.

## Planned

Next: Caella's magic trial, Ronnie's survival/material trial, starter weapon,
Rulo/Bull combat, final Palomo encounter, Magic Box, The Fool and narrative
exit. MAP02 is currently an actor test field; story sewers are still pending.

The established sequence continues through V4.34 world/travel foundations,
V4.35 calendar/weather/events, V4.36 physical hazards and V4.37 Tarot/Trucazo.
**V5.0 reorganizes programming modules**; V5.1 adds thermal exposure and later
V5 work expands persistent resources and marine biomes. Remaining weapon
art, loot, faction consequences, perception/formations, sieges, co-op/PvP,
world persistence and the complete campaign are tracked in PROJECT.md.

## Pending validation

Author acceptance of 0h audio and Windows application remains pending. 0g's
earlier reference-only checks did not establish audible looping or prevent
the native conversation sound overlap. Current results and limits are in
[PROJECT.md](docs/PROJECT.md); gameplay acceptance of 0f remains intact.

## Build and run

Apply **APLICAR_4_33_0h.cmd** from an extracted patch folder outside the full
0g project and provide its root path. The applicator verifies the audited
files, archives originals, installs the delta, relocates useful source art,
retires known obsolete helpers and rebuilds the PK3. Unknown local files are
preserved; conflicting edited files stop application before writes.

Double-click **run_dev.bat** to build and play with the supplied machine's
existing engine/IWAD paths. To build independently, from any working directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\path\CaelumArgenteum\build_dev.ps1"
```

Only src enters build/caelum_argenteum_dev.pk3. The builder writes files-only
ZIP entries and replaces the previous build atomically after verification.
Python is not needed to build or play. Source generators in assets/generators
are optional editing utilities; their dependencies are listed in ASSETS.md.

## Documentation and project rules

**Update this README and the five canonical documents with every release.**
Keep implemented, planned and pending-validation status distinct. Integrate
new subjects into existing chapters; preserve superseded information in the
history and keep patch-specific utilities out of the active project.

| File | Purpose |
| --- | --- |
| [PROJECT.md](docs/PROJECT.md) | Principles, complete roadmap, folder audit and current validation. |
| [SYSTEMS.md](docs/SYSTEMS.md) | Controls, social odds, crafting, economy, storage and dialogue rules. |
| [MAP01.txt](docs/MAP01.txt) | Full authorial story/specification and implementation boundaries. |
| [ASSETS.md](docs/ASSETS.md) | Audio/art inventory, provenance, source generators and accepted framing. |
| [HISTORY.md](docs/HISTORY.md) | Consolidated previous records and superseded decisions. |

Use English code/identifiers and Spanish explanatory comments. Prefer native
engine features and shared authoritative systems; protect accepted gameplay
and author-owned lore/balance. Deliver changed files and report actual tests.
Keep useful source assets and required license notices. V5 source refactoring
must preserve save/input compatibility through incremental changes.

Run `python validate_project.py` before preparing a release to check version,
documentation, structure and audio references. Development engine/IWAD files,
test observers and archives are not part of the playable PK3 or source delta.

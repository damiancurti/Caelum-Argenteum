# Issue #233 validation - 5.3.6

CA233-01 (origin 5.3.6 / #233) passed the remaining author checks on
2026-10-14. The author explicitly confirmed: "Todas las pruebas esas ya las hice
y dieron correcto." Held/released controls, rotated and overlay maps, native numbered marks and custom/unbound bindings passed; controller navigation remains optional where applicable.
This completes the previously partial acceptance, with no reported failures or
qualifications beyond optional hardware applicability. Technical evidence remains
separate; this records author confirmation, not a new instrumented run.

Earlier validation and staged acceptance records follow; pending labels below
describe those earlier checkpoints and are superseded by this confirmation.

Baseline: `8f5cf9d8` (accepted #232 / 5.3.5). Windows 11, GZDoom 4.14.2,
Vulkan, isolated INIs, fixed seed 184, unpaused background and 5% audio.
Final matrix: **8 native runs, 88 assertions, 10 native-save comparisons and
16 inspected captures**. Static validation and normal build results are retained
adjacent to `evidence.json`; the collector requires no validator errors and
byte-equal uncompressed members between the normal and frozen runtime packages.
Exact commands, runtime/fixture hashes and exit codes are in the manifest.
Engine, IWAD, PK3s and native saves remain local.

The native audit retains the ten numbered marks, automap center and bindings.
GZDoom exposes `level.GetAutomapPosition()` but no cursor-to-world projector.
The author approved center placement and list selection. `TextEnterMenu` supplies
the native text/control-grid path; its supported editing is append/backspace.
The native `events.cpp` command writer uses a 16-bit payload byte count; our
request checks the exact fixed/string overhead before sending. No gameplay
note-count limit or new default binding is imposed.
Audited engine commit: `99aa489d09015a95bb78df2b30ede29f328cc874`.

`edit-final-01` exercises real native menus and the production network command:
empty/idempotent migration, invalid map/category/ID/text, matching and stale
pointer guards, text/draft cancellation, duplicate save submission, stable edit
identity, cancel-first delete, confirmed deletion, stale revision rejection,
long Unicode content and actual paper markers. It seeds fixture text into the
native draft; it does not claim physical keyboard typing. It verifies that
manual bed/transport categories add no discovered POI.

`reload-01`, `hub-01`, `old-save-02` and `migration-01` use genuine engine-created
saves. They retain exact note contents/coordinates, native numbered marks,
geometry and original character values, including the complete identity profile
and allocations. The latter are compared after resolving native object-table
references: relocation indices may change without changing their values.
The long Spanish/English text is also compared to its exact expected Unicode
string after decoding the serializer's individually escaped internal UTF-8 bytes.
Identical coordinates on MAP04/MAP05 remain distinct notes. The unchanged old
save/package is retained for recovery; no downgrade of new-schema saves is promised.

`layout-es-02` (800x600) and `layout-en-02` (1920x1080) cover all six categories,
normal/large UI and message scales, native rotated/full and overlay rendering,
outside-map editing with creation disabled, empty-text feedback and rejection
of an oversized native command. The overlay state is asserted before capture;
native deferred toggles require intervening tics. Text is abbreviated only in
list rows/map labels; the full text stays in the record and scrollable editor.
Existing native survival notices retain their size and lifetime.

`privacy-01` reuses the unchanged local native-engine copy and isolated bot
configuration from #232. Two native players retain different personal notes,
and derived private markers are suppressed with multiple participants. This
checks ownership/privacy, not complete multiplayer gameplay or networking.

Earlier local diagnostics remain in `build/issue233`: syntax iterations,
the first old-save script's missing UI completion event, and overlay captures
taken before a deferred toggle settled are not final evidence. The first old
save remains untouched; the final baseline uses `c233-old-verified.zds`.
Only explicitly selected successful runs enter the manifest.

Reproduce fixtures with `python assets/validation_536/prepare.py`; use
`--fixtures-only` when retaining the frozen production package. `run_native.ps1`
accepts the exact manifest arguments. The older-save load uses
`-RuntimeAlias load-current/baseline.pk3` to preserve its native archive basename.
`collect.py` copies selected evidence and checks native saves/package equality.

For ordinary editing, run `powershell.exe -NoProfile -ExecutionPolicy Bypass
-NoExit -File assets/validation_536/handoff.ps1`. The terminal remains open and
`Probar233` starts a fresh MAP04 test. On 2026-10-14 the author confirmed all
five presented editing steps in CA233-01: center placement with accented text
and category selection; mouse/keyboard editing; cancelled edits/deletions and
confirmed deletion of a separate note; long text, zoom/pan and save/load; and
manual Bed/Merchant categories without service discovery or access. Session
`author-20261014-064047` used MAP04 and runtime SHA-256
`6a274349bdf886cf42fe499325b86d856eb233977b7ab7d2283af810a822a662`.
This physical-input acceptance is separate from the scripted matrix. Remaining
held-input, map-mode, numbered-mark/binding and optional controller checks stay
in CA233-01; they were not included in the five presented steps.
No merge or issue closure is claimed. Authored registrations (#234), multi-mission
tracking (#235) and Journal navigation (#236) remain separate deliveries.

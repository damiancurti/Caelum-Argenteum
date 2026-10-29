# Combat contact - #502 / 5.8.12

The approved0.01m2 impact patch and ten world seconds now reach native melee
receivers. The cleaner contact surface gains concentration; the source retains
its value. Body dose uses80/bodyKg. Armor/clothing or the actual blocking item
receives contact before skin. No damage or balance constant changed.

Player weapon traces, punches, modeled NPC weapons and carried resident tools
share the adapter. Physical receiver hooks run after existing evasion/block
decisions and before wear, including damage absorbed completely by defense.
NPC weapon/shield/armor models lazily own shared revision1 state; absent fields
from earlier saves start clean without resetting existing native item/body dirt.
No Tick or actor registry/global scan was added; each hit handles two endpoints.

GZDoom4.14.2 defaults A_CustomMeleeAttack to None. The three authored call sites
therefore mark only their synchronous native delivery. Generic unmarked None
hits cannot inherit it. Existing player None damage bypasses directed defenses;
that behavior is preserved and explicitly reported in SYSTEMS/CA-KP-165. The
manual shield case uses directed Melee; the natural bite retains native None.

87 executed native assertions pass across11 selected serial runs (83 on the
final runtime,4 on the accepted previous runtime). Count PASS lines, not counters
serialized in savegames. Cases cover both transfer directions, body mass, equal
concentrations, selected weapon versus fists, covered skin, shield interception,
evasion, non-contact damage, Box protection, modeled NPC loadouts, native dropped
items, actual sword hit/miss, natural native None delivery/context cleanup,
current save/load and hub return, prior-runtime save migration/original rollback,
and accepted calendar-sleep/repair-cleaning regressions. Raw logs, arguments,
hardware, hashes and counts are in report.json and native/.

All16,894 package members equal source bytes. All169 maps and13,826 art members
match calendar-final01. Final package SHA256:
`337013c42d15dffe45bd626f434463966e8561e0c6fc7f635c6e3548c3aa20ec`.
The addon generator is deterministic. Static validation passes.

Performance comparison, same isolated two-body scene,20 contacts/700 tics,
1280x720 Vulkan/60FPS cap,5% audio/unpaused background: final mean native render
callback16.666ms,p95 16.981,p99 17.183,worst17.522; accepted baseline mean16.666,
p95 16.979,p99 17.190,worst17.538. Both recorded1199 callbacks. PresentMon was
attempted but Windows denied trace access. These callbacks measure renderer
cadence, not application presents, displayed frames or GPU execution; this short
scene cannot establish campaign-wide FPS or siege performance acceptance.

Development failures remain in ignored build/issue502-hygiene. They exposed
reserved State identifiers, unsupported inline array syntax, deferred NPC
PostBeginPlay, native CreateTossable returning the original item, a renamed
fixture EventHandler preventing old-save reconstruction, and friendly-fixture
range rejection. The final fixtures wait for native initialization, retain
stable save classes, preserve returned item identity and use hostile actors
with autonomous AI disabled. The real None-delivery integration gap was fixed
and retested on the final runtime. No unresolved native failure remains in this
slice. The initial performance fixture required UI-owned callback fields; its
final comparison passes while retaining the PresentMon permission limitation.

CA502-CALENDAR-01 was accepted by the author on2026-10-25 (e25647a3).
CA502-COMBAT-01 passed author review on2026-10-25, after clarification
of the reset-per-impact controls. Its pending entry is retired. The live fixture presents
readings from the last actual attack; F2 stages controlled concentrations each
time, and ambient exposure continues afterward. It invokes native attack paths
without claiming first-person animation validation. Agent inspected the visible
native overlay showing sword80/target0.8/body0; all five supplied scenarios also
pass native execution. Toilet/treatment remain independently pending.

Generic actor ambient exposure, continuous actor brushing and NPC household
cleaning are separate unfinished work. This continuation does not complete#502
or V5.8. No art, map, recipe or unapproved calibration was introduced.

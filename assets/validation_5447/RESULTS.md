# Production siege adrenaline — #361 / 5.4.47

## Final author revision: NPCs and monsters only

The author explicitly excludes the player to preserve seal balance. The final
rule retains maximum adrenaline only for registered siege attackers/defenders;
the NPC implementation is unchanged. CaelumPlayer, CaelumPlayerResources and
CaelumSiegeEncounter are restored to their pre-issue f3fedf95 source. This removes
every forced player refill, player formula change and the now-unused transient
player-port cache. Native player gain/decay, needs/wound penalties and seal
cost/exhaustion remain unchanged everywhere. Earlier preview saves keep their
current reserve and follow those ordinary rules; no artificial reset is added.

Revised controls assert ordinary player reserve/penalties during the active
siege, exact seal cost and eventual exhaustion, while repeating the NPC formula
and lifecycle controls. Saved controls cover the old battle, new battle and
both hub legs, and city/house saves written by the superseded player-inclusive
candidate. New evidence is kept separately in npc_evidence.json/zip and
npc_delivery_checks.json; the original archive below remains historical.
The saved-scene observer is protected from ordinary attacks so it can write
saves; damage preservation is checked separately in the isolated controls.

The first revised city attempt produced no focus-city.zds despite completing
its rule assertions; the next load failed because the file was absent. This is
not counted as a completed save test. Revised fixtures assert that the observer
is alive, protect it from ordinary attacks, allow more time for native save
completion and explicitly require the written save before attempting reload.
The next hub draft reached both maps but exited before its final city assertion
ran; its earlier DONE markers are not a complete round-trip pass. The final
fixture waits after each network request and emits DONE only after checking all
three checkpoints and the final map. The archive verifier also requires that
ordered city/house/city evidence. Other successful single-checkpoint controls
remain valid for their actual recorded runtime and fixture.

FPS remains deferred. The author accepted revised NPC-only CA361-01 on
2026-10-18: "Listo, dio correcta la prueba." The private preview's F9 contrasts
NPC maxima with the player's ordinary reserve; house/city travel must never
grant a player refill. This explicit acceptance is separate from the native
evidence below; no new engine run or FPS measurement accompanies it.

Six complete revised native runs pass **6,928 assertions**:

| Revised case | Assertions |
| --- | ---: |
| Isolated NPC rules and player/seal exclusions | 642 |
| Old author battle save | 1,578 |
| Current city save and complete city/house/city trip | 3,128 |
| Earlier player-inclusive city save | 1,568 |
| Earlier player-inclusive house save | 6 |
| Current house save | 6 |

Independent review confirms that player/resource/event code matches f3fedf95;
the removed cache fields were transient. Normal build and project validation
pass, and all16,379 normal members match both source and the tested runtime.
The earlier evidence archive remains unchanged. Use archive.py --npc-only for
the revised archive; verify_evidence.py now checks this final NPC-only delivery.

## Initial candidate: superseded player-inclusive scope

The author requested production adoption and explicitly deferred FPS evaluation.
This delivery verifies behavior and compatibility; it contains no new benchmark
or assertion of a measured performance gain. Existing caches retain their
automatic 500-body threshold; the siege gameplay rule remains active at lower
population until the event ends.

## Implemented scope

Registered MAP03 attackers, Zupay, reinforcements and bound defenders retain
their existing individual maximum. The player qualifies while alive in the
active city. Peace, victory, unrelated bodies and private houses do not force
the maximum. House entry resumes ordinary decay without erasing the reserve;
returning restores it. Death does not refill; a living resurrected member
qualifies even if the encounter retains its historical death record.

The exact saturated wound formula skips patience mitigation arithmetic while
preserving health-state classification and other modifiers. Hunger/thirst still
consume resources and cause critical damage. Combat timers, active resource
recovery, finite inventory, thermal effects, elemental slowing and immobilization
remain. Channel validation/spending continues, followed by the siege refill.
Incoming player damage refreshes adrenaline before pain/interruption calculation.

NPC membership uses existing owned references. The player uses a transient port
reference in the existing siege event handler, resolved once after loading and
maintained through native spawn/destruction/travel. Empty results are cached;
no new recurring actor scan or serialized schema is introduced.

## Native correctness and compatibility

Private fixtures use the exact normal source bytes. The isolated map replaces
only MAP03 in a separate fixture. Its reference wound method is extracted from
the pre-change commit f3fedf95, rather than rewritten to mirror the candidate.
Across 100 health levels, three patience values and both cached/uncached paths,
all six assigned outputs match exactly. Other controls cover scope, maximum
changes, cache refresh, prediction authority, combat timers, consumption/damage,
thermal/elemental penalties, stun, channel spending and first incoming damage.

Real private author saves supply the old MAP03 battle and CAH008 interior. The
observer checks every living registered body once per checkpoint, not every tic.
The first successful city checkpoint contains 985 attackers and 587 defenders;
the player is exactly 1084/1084 adrenaline. Current-save hub travel checks actual
MAP03 → CAH008 → MAP03. House decay is 1083.7143/1084 after one ordinary step;
city return restores the maximum. The old interior save and a newly saved
interior receive separate reload checks. A final rollback loads the newly saved
battle under the preceding 5.4.46 runtime and confirms ordinary behavior returns.

Six final runs pass 6,830 assertions:

| Case | Assertions |
| --- | ---: |
| Final isolated rule/formula controls | 642 |
| Old city save under current runtime | 1,576 |
| Current city save and both hub legs | 3,122 |
| Old house save and city return | 1,484 |
| Current house save reload | 4 |
| Current city save under previous runtime | 2 |

Final run counts and hashes are authoritative in evidence.json. Cumulative DONE
markers within one run are counted only once, using the final total. The engine
is GZDoom 4.14.2, unpaused in background at 5% audio, one process at a time.
No 6,000-simultaneous case is run. No PresentMon collector is launched.

## Qualified failed drafts

- checks01/02: the private port was parked before native spawn initialization,
  so the player could not find/publish it. A private subclass now suppresses
  deployment through Tick while retaining normal native spawning. No production
  lifecycle workaround is made for this fixture defect.
- checks03: one-point weight damage was legitimately rounded away by toughness.
  The preserved-damage control now uses already-resolved drowning damage and
  separately asserts HP loss and pain mitigation. checks04 passes 642 controls;
  final-checks repeats them against the final runtime.
- old-city01: the initial console wait ended before the loaded scene processed
  its observation/save requests; no completion marker or new save was produced.
  Final live scripts use capped tics and sufficient waits. This is not a pass.
- old-city02: the real old save exposed a production defect: eager WorldLoaded
  initialization alone left the restored transient player reference empty.
  NPC checks passed but the player stayed at zero. The final lazy-once rebuild
  resolves it; old-city03 and both hub/save controls verify that fix.

Independent review identified the initial frequent port lookup and the seal
channel's between-update spending case; both were corrected and tested.

## Reproduction and evidence limits

Run prepare.py with a fresh `--directory issue361-...`, then the sequential
assets/validation_5422/run_native.ps1 wrapper with `baseline.pk3`, `city.pk3`
and the generated cfg. `checks` uses the isolated MAP03. `live` requires the
private author saves in build/issue354-preview01. `rollback` requires the prior
complete normal runtime plus the newly generated focus-city.zds. Never substitute
a fresh campaign silently for a saved-state control. Archive text with archive.py.

evidence.zip includes logs, executed commands, run metadata, source hashes and
private fixture text, including failed drafts. Engines, IWADs, maps, PK3s and
private saves remain local. The normal package contains none of these probes.
The six older CA318/CA327 author checks are explicitly accepted in PR360.
CA361-01 is the sole new author check; native results do not claim that approval.

Delivery gates pass: project validation, document-index freshness, Python syntax,
normal build and exact equality of all 16,379 packaged members with both source
and the final tested runtime. All 117 archived text members verify by SHA-256.
Both original author saves retain their known hashes. See delivery_checks.json.
The private preview opens the real saved battle, with F8 for house/city travel,
F9 for adrenaline values and F10 to restore the starting copy; its open terminal
explains the check. It is not shipped in the normal runtime.

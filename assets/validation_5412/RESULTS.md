# 5.4.12 / #245 - Miracle

This focused patch stacks on accepted #244 (05fa1855). Production adds Priest
User4 release, a moving recovery area and authoritative player/NPC restoration.
It does not implement the other class abilities. CA245-01 passed author review on 2026-10-15.

## Approved contract

The author confirmed on 2026-10-15: 3% of each recipient's current maximum Health,
Lucidity, Anima and Air per second, additive to ordinary recovery; moving area
with entry/exit; caster and native allies, excluding neutrals/enemies; direct sight
at every pulse; first pulse after one second; only the strongest overlapping
Miracle; renewal uses new potency and max(remaining, new duration), preserving
pulse phase. Shared Eloquence/Empathy scaling and paid casting remain authoritative.

Integer Health retains its fractional remainder separately from natural recovery.
Player/NPC revision 1 initializes it idempotently for old saves. The caster-owned
revision-1 inventory stores range, rate, remaining time and next pulse. Equal
potency uses native player order. Suppressed pulses do not queue. Forecast travel
rejects both the caster's area and an eligible external area.

## Static and normal packaging

Run `python build_dialogue_index.py build`, `python build_document_index.py`,
`python validate_project.py` and `powershell -NoProfile -ExecutionPolicy Bypass
-File build_dev.ps1`. evidence.json records final results and member comparison
with the frozen native runtime. Only src is packaged; fixtures and IWADs remain
development inputs. No Doom assets or engine executables are added to this patch.

## Isolated GZDoom 4.14.2 evidence

Prepare with `python assets/validation_5412/prepare.py --directory issue245-final`.
Run each case with `powershell -NoProfile -ExecutionPolicy Bypass -File
assets/validation_5412/run_native.ps1 -Directory issue245-final -Label <case>-01
-Script <case>.cfg`. For load/load_prep add `-LoadGame miracle.zds` or
`-LoadGame preparing.zds`, respectively. The savedir supplies the path; the engine
prepends it even to a full Windows path. Runs are sequential, unpaused in the
background with 5% audio. Exact arguments, runtime/fixture/engine hashes, exit
codes, completion markers and timestamps are in evidence.json.

- contract: player/NPC four-resource consumers, current maxima, caps, fractional
  Health, ordinary regeneration, native allegiance, real wall and range, moving
  membership, social snapshots, renewal and strongest overlap. The secondary
  caster is an isolated actor fixture, not evidence of network multiplayer.
- casting: actual native User4 progressive debit, cancellation without refund,
  release and reuse. Unchanged shared hold/rebind/menu/attack lockout evidence
  remains in validation_544; it is not falsely reported as rerun here.
- cadence: no early pulse, first at one second, ten real timed pulses including
  the final second, all four NPC resources, and no pulse after expiry.
- save/load: saved mid-period; exact phase, one pulse per loaded second, no
  repayment; serialized player/NPC fractional remainders and revisions; hub
  round trip, expiry and death. Saved native preparation releases only once.
- compatibility: old 5.4.11 neutral-save upgrade; optional bridge removes the
  unsupported area or cancels preparation without refund; re-upgrade the
  bridged copy. Originals remain untouched. This is not campaign-wide acceptance.
- author preview: actual native cast and readable overlay, visible ally restored,
  enemy/occluded ally untouched; inspected engine screenshots.

Final gameplay runtime SHA256:
`c6af1c023a16f7c973b90a3a8f6b75319c7bfa8bc0faafd709713c6afa7efe93`.
The author fixture additionally resets its F7 position toggle; gameplay is identical.
The per-run evidence distinguishes each fixture hash.

## Preserved iterations and limits

v1/v2 contract checks exposed fixture initialization before deferred PostBeginPlay:
the normal Mandinga profile replaced artificial resources, leaving bodies full.
The test subclass now sets artificial reserves after its native profile initializes;
v3 and final contracts pass. No production balance was changed to satisfy the fixture.
One v3 load invocation supplied a full Windows path and was rejected by GZDoom's
savedir prefixing; corrected relative-name load passed. An attempted final load
was refused by the one-engine guard while the save suite was still running; no
second engine launched. Evidence retains these failures instead of counting them
as successful checks. v3 is preliminary; final repeats the changed runtime and
adds saved fractional-recovery checks.

The copied-save bridge is optional tooling for 5.4.11 only. It cannot make that
old runtime understand Miracle; it removes unsupported temporary state from the
copy, without refund or replay. Restore the preserved original to reverse this.
Fractional recovery fields unsupported by 5.4.11 are absent on the bridged copy.
No campaign or network multiplayer acceptance is claimed.

## Author check

CA245-01 passed on 2026-10-15: "La prueba dio bien." The offered run exited
with code 0; acceptance.json records exact hashes and qualifications. HISTORY
preserves the result and the confirmed pending entry was removed. PR291 is ready;
no merge or issue closure. launch.ps1 opens the isolated game:
F cast/cancel, F6 reset, F7 ally inside/outside, F8 ally behind the real wall.
The ally begins at 200 Health, 20 Lucidity, 2000 Anima, 200 Air; each eligible
pulse adds 30/3/300/30. The player's ordinary Lucidity recovery remains active;
other natural rates and NPC movement/recovery are fixed solely for this fixture.
The direct launcher opens the game; a persistent PowerShell window was previously
rejected by automatic policy. The author confirmed the offered scenario; no
itemized or campaign/multiplayer result is inferred.

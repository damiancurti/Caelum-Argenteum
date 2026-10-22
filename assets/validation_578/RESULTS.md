# 5.7.8 / #479 - Support calculation foundation (partial)

This is an implementation checkpoint, not delivery of playable support weapons.
It packages the approved role/cost/radius data and a serializable per-effect-class
calculation state. Existing actors, weapons, movement, damage and recipes do not
call it yet. No old item is migrated and no new item is sold or granted.

## Verified scope

Native GZDoom 4.14.2 tests cover M2 at 0/100 and effective levels above 100, all
four role mappings and tier costs, fractional per-tic integration, expiry,
stacking with different caster strengths, duration reset, changing maximum
health, independent benefit/curse state, the 100% factor, unknown revisions and
idempotent initialization. Native save/load checks retain intensity, revision,
fractional remaining time and accumulated fractional health, then compare the
resumed result with uninterrupted integration. report.json records exact counts,
package/fixture hashes and source-byte equality; native/ records environment and
normal process exits. The fixture is deterministic and adds no runtime overrides.
The final result is 56 PASS / 0 FAIL: 51 model assertions and five save/load
assertions, with all final native processes exiting 0. The validator passes at
5.7.8 with 2,499 CONTEXT words. All 16,598 package entries match current src bytes.

The initial fixture used `state` as a local identifier, which conflicts with
ZScript grammar; that parser failure is preserved in diagnostics/model-01.txt.
Renaming the local fixed the fixture without changing production code.

There are no active per-tic hooks or scans in this partial patch. This establishes
calculation and serialization behavior, not combat, frame-presentation, whole-map
performance, item migration or author acceptance. No engine, IWAD, PK3 or save
is distributed. No manual check is added for an unexposed calculation layer.

## Source audit and deferred integration

- CaelumConstants assigns old Book/Statuette weapon types 18/19. Keeping those
  persisted identities for Scepter/Orb is compatible with the approved migration;
  support entries must be separate. Learned essence recipes currently encode four
  implement groups in CaelumCraftingRules.GetUnifiedEssenceWeaponType.
- CaelumPlayableWeapons assigns offensive Quintessence selectors to native slot
  0; CaelumPlayer.GetWeaponFamilyForType uses internal magical family 6. Reserving
  slot 0 exclusively for support requires an authored destination for its old
  offensive selectors, not a blind replacement of unrelated numeric IDs.
- The approved baseline radius is ESSENCE_EXPLOSION_BASE_RADIUS=128. Existing
  offensive Statuette casting applies AbilityRangePercent and the charged linear
  multiplier; Orb must retain that behavior. Initial support has no charge.
- CaelumSealResistance already retains 85% of Quintessence health damage for a
  Quintessence seal. Support mitigation and rare resistance distribution remain
  undecided. The calculation layer returns fractional HP before mitigation; it
  does not authorize bypassing seals or rounding damage once per tic.
- Existing Miracle restores other resources and has global scans. It is not an
  appropriate implementation to copy for health-only local support effects.
- Economy/fabrication/masses, overlapping effect-class identity, selector routing,
  artwork, authoritative recipient integration and full migration remain open.

The author requested postponing questions and manual tests until returning.
The canonical contract/status is in SYSTEMS/TASKS; this report is test evidence.

## Reproduction

Run validate_project.py and build_dev.ps1 with destination
build/issue479/current/caelum_argenteum_dev.pk3. Run prepare.py, then run_native.ps1
with -Checks for smoke, -Script save, and -Script load -LoadGame ca479-state.zds,
using a fresh label for each process. collect.py verifies the final artifacts.

## Subsequent runtime integration (2026-10-22, in progress)

The author's later approvals are recorded in SYSTEMS. Development overlay
`gameplay-04` passed 62 gameplay assertions; `live-01` passed four real-tic
assertions (40 elapsed tics, 2.857142857 s remaining, health 960/1000).
The overlay is only a development diagnostic; the foundation package above is
not the integrated final build. New preparation/fixture sources are tracked.
Artwork, legacy/current saves and final full-package evidence remain in progress.
Author manual tests/questions are postponed during the renewed absence.
Earlier failed iterations remain in local logs; none is acceptance evidence.

`live-save-02` / `live-load-02` also passed four native receiver/inventory/
caster/duration checks after a real save/load. At elapsed tic 41 the loaded
receiver had 960 HP, 2.828571429 s remaining and 6.857142857 fractional HP.
`integration_report.json` records the diagnostic package/overlay hashes; logs
and launch metadata are in native/. The first save attempt quit before the
engine wrote its file; the corrected fixture waits five frames before quitting.
No production save defect was inferred from that fixture error.

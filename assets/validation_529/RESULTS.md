# 5.2.9 / #192 - Personality, magical power and bell

Author acceptance, 2026-10-11: CA192-01 passed without qualifications.
The author authorized the #188/#192 merges and closures on the combined 5.2.9
build. HISTORY records the confirmation. The agent report below preserves its
original test scope and delivery-time pending status.

Baseline: 52e3bd01 (#188 / 5.2.8). Windows 11, GZDoom 4.14.2, Vulkan,
development Doom II IWAD. Native runs are isolated, unpaused in the background,
at 5% audio. This is agent evidence; CA192-01 and CA188-01 remain pending author
gameplay acceptance. No save, engine, IWAD or generated package is committed.

## Native verification

The matrix covers all twelve options and all 81 combinations, profile copying
and packing, old defaults, adrenaline/evasion, physical and magical critical
chance/caps, shared power and actual thermal transfer. It verifies all bell
tiers, ordinary/charged and primary/secondary variants: 12 individual shots
each, preserving per-shot damage, payload, critical metadata and cast cost;
each shot independently traverses the native damage receiver and half R.
It also checks every firearm tier/ideology, combined shield/armor absorption,
final caps, soldier shields and legacy wizard navigation.

The collision fixture fires moving projectiles into an actual player and NPC,
checks one preparation callback, final HP loss and restored guards. It covers
physical/critical and explosive direct hits, repeated regional blast budgets,
zero-damage outcomes, invulnerability/dormancy/evasion, forced/sentinel
preparation bypass and real soldier shield damage/wear. The existing #188
status/impact matrix is separate evidence; this patch does not claim a second
manual campaign run.

The native creator fixture clicks all twelve choices, tests keyboard cycling,
back navigation, summary, leaving/reopening the draft and confirmation into the
authoritative profile. Spanish 1280x720 and English 1024x768 captures were
visually reviewed. These are native callback/render tests, not physical mouse
or controller-device acceptance. Creation still requires author gameplay review.

Save tests load a protected 5.2.8 character, assign Normal/Normal/Normal/Center
once without resource refill, then select another personality and save/reload.
MAP03-to-MAP02 travel retains the profile. Rollback loads the untouched original
on its original package; downgrade of a newly written save is not promised.

Final run labels, counts, hashes and power-request release are recorded in
AUDIT.json and the final evidence summary below.

## Warrior/mage comparison

The comparison uses the same Human, male, normal-height Warrior+Warrior and
Mage+Mage profiles at each tier, with the creator's recommended allocation.
Warrior uses Aggressive/Instinctive/Rebellious, heavy armor and primary sword;
mage uses Patient/Calculating/Disciplined, magic armor and ordinary bell.
Armor and weapon tier match T1/T2/T3; there is no jewelry or active Tarot power.
All three attacker and defender ideologies are reported separately.

T1 has no Tarot. The T2 test assumption is 39 cards: majors 0 through 10,
and minor ranks 0,1,2,4,5,7,8 in each suit (Ace,2,3,5,6,8,9). That yields
exactly +50% general attributes and +1.6 flat to each attribute before the
percentage. T3 owns all 78 cards: +100% and +3 flat each. The exact half-deck
selection is a reproducible test fixture, not a new acquisition/balance rule.

Each target is a controlled 80 kg Human with Toughness 20, intact heavy armor
at matching tier, and optionally a frontal tower shield at matching tier.
The target's personality supplies the chosen defensive ideology. R=120.32;
direct magic R/2=60.16. Use noncritical torso hits, no evasion, no active
buffs, and reset equipment before each row. The production solvers calculate
anatomical grade, absorption and final HP rounding. Tower T3 has 100% nominal
absorption, capped only after defender boost and attacker penetration.

Raw damage is per sword hit or bell projectile, before anatomy/defenses.
Post-armor and final HP are separate columns. Bell potential is twelve times
the independently mitigated result against reset intact defenses; it is not
observed fight DPS, does not guarantee twelve hits and does not simulate armor
degradation during a volley. Full machine-readable rows: comparison.json.

## Corrections during testing

Initial fixture errors involved an unsupported thermal test body, a nonexistent
channel class name, an unavailable console menu command and save paths resolved
relative to GZDoom's save directory. Deferred screenshots initially captured
the next page; waits now preserve the requested page before changing it.
Exploratory runs are not passing evidence; original logs remain under build.

Native full-impact testing found a real ordering defect: Super.DamageMobj
reapplied prepared projectile damage after custom defenses. The final code
prepares the projectile once, defers NPC anatomy until after its shield and
restores a transient receiver guard on every return. Soldier shielding now
participates inside that sequence and retains fractional remainders.
Cross-review also caught channel/javelin penetration depending on a later
equipped firearm; launch snapshots and direct-inflictor checks correct both.

## Reproduction

Run `python assets/validation_529/prepare.py`, then `run_native.ps1` with a new
label and matching fixture/script. `native`, `collision` and `comparison` use
MAP03. `creator` uses MAP01 and the desired `-Language`, `-Width`, `-Height`.
The baseline save uses `-Baseline -Fixture legacy/persistence -Script save-old.cfg`.
Copy production.pk3 to build/issue192/upgrade/baseline.pk3 and use that
`-RuntimeAlias` for upgrade/reload, preserving GZDoom's package identity.
Pass only the save basename to `-LoadGame`. `travel.cfg` starts on MAP03.
Build the final official package with build_dev.ps1; archive_evidence.py checks
every member against src and records source/config/runtime/fixture hashes.
The archive normalizes log whitespace to UTF-8 LF and retains original hashes.

## Selected comparison results

Liberal attacker against Conservative target; full permutations are in comparison.json.

| Build | Tier | Strength | Intelligence | Raw per hit | HP, no block | HP, blocking | Bell potential, no block / block |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Warrior | 1 | 20.0 | 5.0 | 216.58 | 0 | 0 | - |
| Warrior | 2 | 32.4 | 9.9 | 352.77 | 30 | 0 | - |
| Warrior | 3 | 46.0 | 16.0 | 611.06 | 75 | 0 | - |
| Mage | 1 | 5.0 | 20.0 | 253.80 | 61 | 0 | 732 / 0 |
| Mage | 2 | 9.9 | 32.4 | 413.40 | 83 | 0 | 996 / 0 |
| Mage | 3 | 16.0 | 46.0 | 716.08 | 94 | 0 | 1128 / 0 |

## Final evidence summary

| Native run | Passing assertions / result |
| --- | --- |
| final-matrix | 959 |
| final-collision | 40, including owned explosive-weapon wear |
| final-diagnostic | 2; CADEV02 allied blast immunity/counter |
| official-comparison | 126; 108 comparison rows |
| creator-es-03 / creator-en-final | 64 each (62 menu + 2 authoritative-profile checks) |
| save-old-01 | Original 5.2.8 checkpoint produced |
| save-upgrade-final / save-repeat-final | 5 each |
| save-rollback-03 / travel-final | 2 each |

The final official package contains 6,347 source-identical members. All runs
pass with no native failure marker. The earlier Spanish UI and comparison
runs remain applicable: later edits only correct the native impact guard and
explosive wear, outside their tested menu/stat/defense-solver paths. Exact
per-run package and fixture hashes are retained rather than claiming every
run used identical bytes. English captures include the corrected summary help.

Project validation reports zero errors with matching 5.2.9 headers and current
indexes. Cross-review was static and independent of the native runs. The final
blast regression preserves native weapon wear based on prepared damage while
using the supplied explosion amount for HP, and preserves CADEV02 allied
immunity. Keep-awake was released successfully at 19:52:54 UTC on 2026-10-11;
the active power plan is identical before/after. No persistent setting changed.

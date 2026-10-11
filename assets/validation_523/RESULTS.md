# 5.2.3 / #180 allied Mandinga retaliation

Base: fdbb9cc7 (#178 / PR181). GZDoom 4.14.2 on Windows 11/Vulkan,
isolated configs and saves, no autoload, RNG180, unpaused background execution
at 5% master volume. Original native arguments/package hashes and raw log hashes
are retained in runs.json. Logs are whitespace-normalized; no engine, IWAD,
generated PK3 or save is distributed.

## Native evidence

- base-02/base-03 reproduce the report on the original runtime: real paid
  racial breath creates the native burn, health drops from 728 to 717, and the
  victim switches from the player to the emitting Mandinga. These are expected
  regression failures, retained as evidence.
- fixed-03 passes all eight assertions on the final runtime. The same contact
  and health loss occur, but the victim keeps the legitimate player target.
  Accidental target/lastenemy references clear; actual player and opposite-
  allegiance damage still cause retaliation. Native Thing_Hate remains valid.
- dense-01 repeats the behavior with 500 additional offscreen living combatants
  and verifies the real automatic HighDensity policy is active. Individual fire
  contact/damage and valid enemy reactions remain. Extra bodies are passive test
  population, not evidence of a complete siege battle.
- migration-02 loads a baseline save containing mutual Mandinga target
  references. The same actor instances clear those references without healing
  their saved health. Native simulation resumes; no state/actor replacement or
  serialization field is introduced.

The fixture keeps the two main actors stationary for reproducible contact, and
suppresses the victim's own breath during observation. It uses actual racial
breath, burn status and DamageMobj, not a stand-in damage formula. After proving
the baseline bug, the old-save fixture freezes state actions and restores its
Anima/Air so resource-recovery AI does not replace the mutual targets before
saving. This setup is distinct from the actual live-burn reproduction.

## Diagnostic corrections

base-01 could not compile because TIDtoHate is read-only; the fixture now uses
native Thing_Hate. fixed-01 used a one-point synthetic hit that armor rounded
to zero; enemy-retaliation checks now reuse the observed burn pulse (14 before
defense), and pass. migration-01 correctly rejected the initial save as a
mutual-fight fixture because recovery/state AI had replaced its targets before
serialization; base-03 and migration-02 preserve and verify them explicitly.
All failed runs remain in the evidence. Dense/migration checks use the same
Mandinga implementation as fixed-03; only release diagnostic text changed.

## Verification and acceptance

The guard extends the native OkayToSwitchTarget hook, then delegates other
cases to Super. It honors IsHostile and TIDtoHate instead of granting fire
immunity or disabling retaliation globally. Engine references:
GZDoom g4.14.2 src/playsim/p_interaction.cpp (OkayToSwitchTarget) and p_mobj.cpp
(IsHostile); declaration in gzdoom.pk3:zscript/actors/actor.zs.

static.json records validator/build status and equality of the normal PK3's
unpacked members with the final native-tested source. Reproduce with prepare.py
and run_native.ps1 using the recorded labels' arguments (choose new labels).
The helper stops only its own isolated process after CA180 DONE; such recorded
termination is intentional. The baseline save script exits normally.

CA180-01 remains pending author acceptance, alongside CA147-01, CA177-01 and
CA178-01. Native isolated results do not claim full campaign acceptance or a
measured performance improvement from this targeting change.

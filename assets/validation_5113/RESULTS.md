# 5.1.13 / #160 - Argento's silver-key handoff

GZDoom 4.14.2, Windows 11, Vulkan. Sequential native tests, unpaused background,
5% audio. Temporary keep-awake released without changing the Windows power plan.
CA160-01 remains pending author acceptance; CA158-01 is carried forward.

## Cause and correction

The protected `llave-plata` checkpoint satisfies the tutorial requirements, has
capacity, and still has one key owned by Argento. `GiveSilverKey` incorrectly
called the ordinary pickup guard before releasing that foreign ownership.
The generic dialogue refusal therefore did not mean the player already had a key.

The authorized handoff now uses `keeper.RemoveInventory(key)`, performs normal
pickup validation, then attaches the same instance to the player. Failure returns
that same instance to Argento. General foreign-owner rejection, weight, quest
gates, native locks and save schema are unchanged. No replacement is spawned.

| Run | Passed / failed | Meaning |
| --- | --- | --- |
| baseline-b | 10 / 6 | Correct gates and custody; eligible handoff, ownership/weight, lock, repeat and held-token checks reproduce the defect. |
| regression-b | 16 / 0 | Correct action transfer, capacity rollback/retry, identity, key count, weight, locks, token refresh and no repeatable action item. |
| reload-b | 4 / 0 | Single key stays with the player, lock access/readiness persist, and another handoff remains idempotent. |

The fixture invokes the native GiveItem AUTOACTIVATE inventory action via public
`CallTryPickup`, with `ConversationNPC` restored to the existing Argento. It does
not grant the key directly, change the original save, or claim physical mouse/key
acceptance. Missing keeper, unanchored keeper and missing tutorial flag are tested
temporarily and restored. Capacity is temporarily set below load to exercise
rollback; the original capacity is restored for the successful attempt.

## Rejected attempts and reproduction

Initial local fixtures used the reserved name `Action` and then protected
`TryPickup`; neither compiled and neither counts as engine evidence. The two
owned startup-error processes were stopped before another run was launched.
The first runtime candidate (`regression-final`, 10/6; `reload-final`, 1/3) still
failed because `DetachFromOwner` is only a virtual hook, not native unlinking.
Those rejected-attempt logs and records are retained here. `RemoveInventory`
corrects the actual ownership chain; final evidence is explicitly `*-b` above.

For local reproduction, preserve the original checkpoint at
`build/issue160/llave-plata-original.zds`, with the matching previous package at
`baseline/caelum_argenteum_dev.pk3` and current package at
`candidate/caelum_argenteum_dev.pk3`. Run `prepare.py` for deterministic add-ons,
then `run_native.ps1` with fresh labels and the package/add-on/load/script
arguments recorded in `*-run.json`. Run checks before reload. Supply installation
paths as needed and never overlap GZDoom instances. `finalize.py` verifies the
retained labels, all packaged source bytes, original-save integrity, deterministic
fixtures and power release. Its private `original-record.json` refers to this
author's save06.zds; do not substitute an unrelated save.

No save, engine, IWAD or PK3 is distributed. RESULTS.json records hashes and
native counts; STATIC.json records project validation and diff checks. The branch
depends on #158 / PR159 and preserves its outstanding author check.

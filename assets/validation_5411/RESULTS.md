# Survival Instinct - #244 / 5.4.11

Focused patch based on accepted #243 commit `42f4866a`. Explorer User4 uses
the shared class lifecycle and snapshots a 3x beneficial-power factor for ten
seconds times that power. Evasion, physical/magical precision and critical chance,
and gameplay-earned Adrenaline query this contribution at their real consumers.
Saved attributes and critical damage are unchanged. Tutorial/debug reserves
bypass the bonus; combat gains receive it exactly once. Renewal uses the new
potency and max(remaining, new duration), without accumulation.

## Native evidence

GZDoom 4.14.2 / Windows 11 / Vulkan; one engine, unpaused background simulation,
5% audio. Exact runtime/fixture hashes, commands, completion markers and exit
codes are in evidence.json. Fixtures, saves and development IWADs do not enter
the production package. This is isolated evidence, not campaign or multiplayer
acceptance. The final runtime differs from v2-v5 only in the two release labels
and the subsequently approved renewal policy, covered by the final contract.
Static validation passes with no errors and CONTEXT at 2,418 words. Normal
build_dev.ps1 packaging succeeds; all 16,161 members match the frozen runtime.

| Preserved directory / run | Coverage |
| --- | --- |
| issue244-manual-final / contract-01 | 22: current-value consumers, caps, nonzero combat gain, independent factors, actual evasion receiver and approved renewal |
| issue244-v2 / casting-01 | 3: native partial payment, second-press cancellation without refund/reuse, full release and cooldown |
| issue244-v3 / weapons-01 | 81: real staff, book, statuette, bell, carbine, shotgun, bow, crossbow and javelin counts, launch critical chance and precision before/during/after |
| issue244-v5 / combinations-01 | 6: actual minor Tarot activation/derived stats, independent expiry, all three personality choices |
| issue244-final / damage-01 | 3: real physical/magical damage receivers with controlled saved critical rolls retain ordinary critical damage after expiry; actual sword consumer |
| issue244-v5 / save-01, load-01 | 1 / 6: revision/potency/time, no repayment, exact tic clock, native hub round trip, expiry and death |
| issue244-v5 / save-prep-01, load-prep-01 | 1 / 1: partially paid Explorer save resumes to one complete release |
| issue244-seed / seed-01 | Neutral 5.4.10 save |
| issue244-upgrade / upgrade-01 | Old save remains without effect and retains Anima |
| issue244-rollback / rollback-01 | Copied active save strips unsupported effect and retains Anima on 5.4.10 |
| issue244-rollback-prep / rollback-01 | Copied preparing save cancels without refund on 5.4.10 |
| issue244-return / return-01 | Migrated copy returns inactive without losing or refunding Anima |
| issue244-author / preview-01 | Native cast and both weapon views expose boosted precision/nonzero gain, then ordinary values after expiry; screenshots inspected |

Final contract and manual preview outcomes are recorded in evidence.json. The
contract checks caps, actual incoming evasion, gain sources, nonzero combat gain,
shared input eligibility, whole-factor Empathy scaling, renewal, restoration,
coexisting racial/posture factors and absence of the superseded immunity.

Preserved failed/qualified iterations: v1 fixture named UpdateAirState instead
of UpdateAirStateEffects. V2 queried Hunter before its first paid tic; the corrected
fixture advances the real racial controller. V3's successful long weapon run
caused the one-engine guard to refuse an overlapping v4 launch; it did not start
a second engine. Visual review of the first preview found a zero health-based
Adrenaline factor at full health, so a zero-equals-zero comparison was inadequate.
The final contract requires a nonzero amount, and the final author scene starts
at 50% health with no regeneration. This is a fixture correction, not a gameplay
balance change. Earlier evidence is not promoted into the corrected gain claim.
The final manual fixture also preserves its artificial Anima reserve on F8;
equipment recalculation must not clamp that test reserve to the ordinary maximum.

## Reproduction and persistence

```powershell
python assets/validation_5411/prepare.py --directory <fresh-name>
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5411/run_native.ps1 -Directory <fresh-name> -Label contract-01
```

Other generated scripts cover casting, weapons, combinations, damage, save/load,
save_prep/load_prep, preview and manual. Load uses `-LoadGame instinct.zds` or
`preparing.zds`. The runner refuses another active engine.

Recipient inventory schema revision 1 stores factor and remaining tics. Old saves
have no invented effect; consumers never bake or divide bonuses into attributes.
`prepare_compat.py` copies inputs to a fresh directory and supports seed, upgrade,
rollback and return modes. The rollback stub is **only for 5.4.10** and cancels
unsupported effects/preparations without returning spent Anima. Preserve original
saves/runtime for reversal; an older runtime cannot retain unsupported mechanics.
This does not claim compatibility with every historical version.

## Author check

CA244-01 passed on 2026-10-15: "La prueba dio correcto". The offered run exited
with code 0; acceptance.json records exact hashes and qualifications. HISTORY
preserves the result and the confirmed pending entry was removed. PR290 is ready;
no merge or issue closure. launch.ps1 opens the isolated
scene: F cast/cancel, F6 reset, F7 combat Adrenaline event, F8 staff/carbine, F9
controlled incoming hit with real probabilistic evasion. The overlay shows both
precision values, equipped critical chances, evasion and gain. Fixture settings
include 100 base precision, fixed base critical/evasion, 10000 Anima, zero Health/
Anima regeneration, 50% Health, an invulnerable player except during controlled
hits, and an immortal target. Normal health/load modifiers remain in the values.
The author confirmed the offered scenario; no itemized or campaign/multiplayer
result is inferred. The direct launcher opens the game;
the persistent PowerShell window was previously rejected by automatic policy.

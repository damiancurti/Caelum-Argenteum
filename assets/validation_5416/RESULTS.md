# #247 / 5.4.16 — Formation Breaker

Implemented on the focused branch based on accepted #260 / PR294. **124
qualified assertions in 30 native runs pass** on GZDoom 4.14.2 / Windows / Vulkan.
Author acceptance **CA247-01 remains pending**; the author is away and no manual
game is launched. The current normal package has 16,165 members, identical to src
and the final frozen runtime `b5ad604382708be1682009b7412b831d1af0182dc6a86b4a2c5a4d145f45f423`.

The native scenarios exercise the real directional commands and User4 dispatch:
standing from crouch, fixed direction/repeated taps, full Empathy scaling, independent
started traversal, native wall/moving-body obstruction, ordinary running expenditure,
water/flight fallback, ceiling denial, interruptions, death, renewal, copied saves
during preparation and traversal, hub transfer, and optional bridged rollback/return.
Direct service checks separately verify final collision Toughness, moving-body
biological cushioning, unmodified ordinary/crushing defenses and prediction guards.
Native bilateral contact delivers equal raw energy and retains the other body's own
defense. Agent visual review found and corrected head/body snapshot lag; final
capture pairs share position/age and fade without persistent actors.

`evidence.json` records each runtime/fixture/log hash, command, assertion count and
diagnostic iteration. Nonvisual runs from `issue247-final`, `delivery` and
`boundaries` are explicitly reused: differences are diagnostic version labels and
head-visual synchronization only, verified member-by-member. Final-runtime checks
repeat affected appearance, movement/contact, saved traversal and paid preparation.
The five earlier #260 regression assertions are not included in this count.

Reproduce from the repository root:

```powershell
python assets/validation_5416/prepare.py --directory issue247-reproduce
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5416/run_native.ps1 -Directory issue247-reproduce -Label contract -Script contract.cfg
```

Run other generated scripts with fresh labels, one engine at a time. `water.cfg`
requires `-Map CA247W`; run `save.cfg` before `load.cfg -LoadGame dash.zds`, and
`save_prep.cfg` before `load_prep.cfg -LoadGame preparing.zds`. `preview.cfg` captures
the trail from a fixed side camera. Scripts use native command waits; failures and
completion counts must be checked, not just process exit.

`prepare_compat.py` takes a recorded runtime, fixture and optional copied save for
seed/upgrade/rollback/return. The old-runtime fixture declares new serialized classes
as inert schema, clamps remaining boosted velocity and cancels the unsupported
transient effect/preparation without refund. It preserves original saves and keeps
spent Anima/identity. This is an optional bridge, not plain-runtime downgrade support.

After the author returns, `launch.ps1` opens the frozen manual scenario, with F for
User4, F6 reset, F7 wall and C third person. The actionable check lives only in root
pending_test.txt. No campaign, multiplayer, performance, merge/closure or other
class-issue acceptance is claimed.

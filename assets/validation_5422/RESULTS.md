# Issue #282 — Gameplay quick-use selector

Version: 5.4.22. Target: GZDoom 4.14.2, Windows 11, Vulkan.
Branch: `feat/issue282-quick-use-hud`; base: `72f4b93b` (#237 completion on
accepted #252). Author acceptance **pending**: CA282-01 in root pending_test.txt.
The author is away; do not launch the manual fixture until their return.

## Implemented behavior

- Bottom-center carousel: selected existing icon, localized name/count above,
  smaller previous/next icons. Empty/single/wrapping selections are explicit.
- Actual owned consumables outside the Magic Box; native inventory order and
  `InvSel` stay authoritative. Ammunition is excluded from usable selections.
- Native `invprev` / `invnext` / `invuse`, with one actual current binding shown
  per action. Controls retains all bindings. The permanent HUD clears the native
  temporary-bar timer so Use works on the first press after selecting.
- Individual water containers show remaining/capacity liters and use Drink
  without consuming their inventory instance. Existing effects, automatic
  provisions, full-inventory behavior and ownership checks remain intact.
- No new save schema. Idempotent reconciliation updates derived eligibility and
  repairs stale native selection pointers from old saves without granting stock.

## Verification

`evidence.json` records **47 passing assertions in 11 final-runtime runs**, plus
one genuine 5.4.21 seed run. Static validation reports no errors; normal packaging
passes and all **16,180 runtime members** match the tested source. Deterministic
fixture repackaging produces the same hash. Final native coverage:

| Scenario | Assertions |
| --- | ---: |
| Eligibility, existing use, quantity, depletion, water and ownership | 23 |
| Native next/previous/use, single-item wrap and repeated empty use | 6 |
| Actual Box storage/retrieval, drop/pickup, separate containers | 8 |
| Current save reload | 2 |
| MAP99 → MAP98 → MAP99 hub travel | 4 |
| Actual old-runtime boxed selection and hidden-container migration | 4 |

Four final rendered captures were inspected: Spanish 1024×768, English
1280×720, Spanish 1600×900 with modern HUD scaling factor 2, and unbound controls
at 1280×720. Labels/icons/keys remain readable, name/count are above the selected
icon, and resource groups stay outside the reserved central width. Earlier
attempts at 2560×1080 were clamped by the desktop to 1924×1061; these do **not**
establish ultrawide coverage. Use the actual PNG dimensions in evidence.

Manual
held-key behavior, personal remapping/menu use and aesthetic acceptance remain
CA282-01; scripted console commands do not claim physical keyboard testing.

`prepare.py --directory <fresh-name>` freezes the current source and isolated
fixture. Optionally supply `--legacy-runtime <accepted-5.4.21.pk3>` for a genuine
previous-runtime seed. `run_native.ps1` requires a completed manifest, one engine
at a time, fresh labels, hidden unpaused execution and 5% audio. LoadGame uses a
save filename relative to the fixture directory; preserve map archive basenames
when migrating old saves. The `migration/legacy.pk3` alias contains the current
fixture code under the old map archive name. Generated PK3s, engine, IWAD and
saves remain local in build/ and are not distributed.

## Diagnosis retained separately

Early compiler/API corrections were confined to development fixtures and
read-only UI adapters: clearscope override inheritance, function-result member
access, protected TryPickup versus public CallTryPickup, and local identifiers
shadowing an icon-size constant. Early fixture assumptions incorrectly treated
DetachFromOwner as removal, omitted Box ownership, expected depleted stack
destruction, and inspected a queued netevent after the next UI command. Corrected
tests use actual ownership, RemoveInventory/native drop, positive eligibility,
and separate native command/report tics.

The initial hub test seeded Hunger at 50%; it crossed below 50 and legitimately
consumed a ration through the already-approved automatic provision rule. An
isolated diagnostic package produced the exact stack: DiningSession.ConsumeItem
→ ConsumeReserve → Serve → Advance → Player.AdvancePersonalTimeTic. This was
not selection/travel loss. The final fixture seeds Hunger/Thirst at 75% to test
quantity preservation independently; no production survival rule was changed.
Failed logs and the intentional diagnostic abort remain under the task's build
directories and are excluded from passing evidence. Absolute -loadgame paths
and a missing legacy map-archive alias were fixture launch errors, not save
migration success. An earlier old-save assertion wrongly required the Food
selection after invalidating a boxed selection; the correct reconciliation
chooses the first eligible native item, the canteen in that inventory order.
Final checks verify that valid choice and all preserved stock. No campaign-wide
or multiplayer acceptance is claimed.

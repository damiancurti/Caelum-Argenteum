# 5.9.6 / issue #424

Explicit faction conditions now control actual trade quotes/commits and door
services. Current civilian merchants, transport and narrative dialogue stay
unaligned. House and intelligence consequences reuse #422 authoritative state.

## Verification

Static validation: zero errors, fresh indexes, clean diff. Native GZDoom4.14.2,
Windows11, Ryzen9 5950X/RTX3070Ti Vulkan, unpaused background at5% audio.

- legacy-01: 1 PASS; original5.9.5 merchant/currency saved without new fields.
- final-rules-03: 33 PASS, zero FAIL. Five actual buy/sell transactions verify
  stock and both wallets at all trade ranks; stale-price and hostility changes
  cannot commit; civilian access survives hostile reputation; generic merchant
  factor rounds once; faction/civilian door access differs only as authorized;
  discounted library quote actually commits its learned pages and payment.
- final-reload: 2 PASS; explicit service condition and reputation persist;
  session price is recomputed from the current record.
- final-hub: 2 PASS after real MAP03 -> CA424B -> MAP03 hub travel.
- final-rollback: original save reloads the preserved5.9.5 package/fixture.
- final-ui: inspected native Spanish library menu; no new diagnostic assertion.

The fixture explicitly assigns its vendor to Unitarios. Production civilian
shops are NOT assigned a faction by this patch. No representative/affiliation
was invented to create a campaign test. Null conditions preserve legacy saves;
the derived price snapshot refreshes rather than owning another reputation copy.

Initial fixture failures: missing existing Magic Box prerequisite, then money
insufficient for all five ammunition-price tiers. Corrected by granting the Box
through its owner and adding physical test currency. Stronger sale assertions
also require nonzero price and the actual SOLD result. No production rule was
weakened. Failed logs remain local. Native hashes/commands: evidence.json.

No new scans, actor layers or per-frame rendering work. Service checks are O(1)
against current references. Existing sliding/gate peer iteration on explicit
interaction is unchanged; native polydoors already use their event registry.
This is functional evidence, not a frame-rate benchmark. Author acceptance
awaits the grouped complete V5.9 handoff. No engine/IWAD/PK3/save is committed.

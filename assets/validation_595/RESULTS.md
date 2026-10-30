# 5.9.5 / issue #422

Two approved quests use the existing quest, property, dialogue and currency
owners. House restitution refunds only recorded contracts, preserving an unpaid
balance if capacity blocks payment. Siege information uses the guard and living
rescued prisoners, retaining knowledge through abandonment and travel.

## Verification

Static validation: zero errors; fresh dialogue/document indexes and clean diff.
Native GZDoom 4.14.2 on Windows 11, Ryzen 9 5950X, RTX 3070 Ti, Vulkan,
unpaused background at 5% audio. Evidence hashes distinguish packages.

- legacy-01: 3 PASS; preserved real 5.9.4 save with two paid rentals and purchase.
- final-migration: 27 PASS; migration, guard recognition, exact 102000-copper
  refund, insufficient capacity, replay protection, abandoned/resumed accounts,
  unpaid-prisoner rejection and real hub travel. Restored map counter is 24;
  the log includes 27 assertions across both maps.
- final-death: 1 PASS; native prisoner death permits guard-only completion.
- final-reload: 3 PASS; property, refund receipt and heard accounts persisted.
- final-rollback: original save loads its preserved 5.9.4 package/fixture.
- final-city: 3 PASS in the real peaceful MAP03 with 600 defenders; caretaker
  spawn, native collision clearance and dialogue reach beside house69.
- final-city-free-02: 4 PASS; repeats placement on final package and restores
  the unpaid original house without inventing a refund.
- final-rental-ui-04: 2 PASS; native reply restores/refunds actual contracts.
  Inspected Spanish existing-contract, restored-property and real-city screens.

The final presentation fix synchronizes tokens before native opening and uses
the existing-contract text without combining two USDF ifitem conditions. This
changed no refund/save logic; final UI and unpaid-city cases cover the change.
A test-only helper initially passed a record instead of a player and failed
compilation; corrected before final runs. Earlier failed logs remain local.

Legacy registry exception: one typed reconstruction per old MAP03 load; at most
four matching prisoners retained, owned by CaelumSiegeEvents. New actors register
by event. The real-city benchmark forces 20 reconstructions only in the fixture:
worst 0.8300 ms; 10000 ordinary four-slot reads 0.2441 ms. These are subsystem
CPU timings, not frame presentation or a claim of 60 FPS.

Author acceptance is pending the grouped V5.9 handoff. No engine, IWAD, PK3 or
save is committed. Rebuild current and run prepare.py; evidence.json records
native commands, package hashes and original-save names. Keep original saves
and the baseline package for reversible rollback.

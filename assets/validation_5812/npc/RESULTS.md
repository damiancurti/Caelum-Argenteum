# NPC exposure - #502 / 5.8.12

Living NPCs supported by the thermal system use the same environmental,
equipment/contact and immersion balance as the player. The existing staggered
thermal schedule provides world time; there is no new Tick or global actor scan.
Each adapter reuses rows and visits only its owner's inventory. Native-backed
resident weapons are not duplicated in their presentation models. Actual body,
item and modeled-equipment concentrations remain authoritative across saves.

121 executed native assertions pass across11 selected serial GZDoom4.14.2 runs.
Counts come from executed PASS lines, not totals restored from saves. Coverage:
bare/covered bodies, mass scaling, actual equipment identity, Box protection,
dropping/unboxing, outward contact, immersion, real NPC scheduling, current
save/load/hub, previous-runtime save/hub migration, original-runtime rollback,
and accepted melee/calendar regressions. Static validation passes; the fixture
generator is deterministic. Source-identical package members:16,895; unchanged
maps:169; unchanged art members:13,826. Runtime npc-final02 SHA256:
`38651311bd4d89888a378cedbfd204a48d2d9b2edc7fd73f95327fccc351b29b`.

The author's crash report confirmed the reproduced hub crash: C0000005 writing
to0xbeefcafe in CAH001. Hidden carriers had used AddInventory without BecomeItem,
leaving world links active. AttachToOwner fixes creation; attachment revision1
normalizes previous carriers idempotently without altering their concentrations.
Both current and previous-runtime hub checks now pass. The supplied report is
retained locally in ignored build, SHA256
`a03655c12364daecdc38de7b32b72a066a647cec74f845ce6e7c44f0ef5598d6`.
See CA-KP-166 and the pinned native Inventory source. Earlier fixture failures
also exposed a reserved identifier, UI/play scope, deferred resident setup and
the need to reacquire hub-owned equipment from its actual owner. All are resolved;
their original logs remain in ignored build.

Matched peaceful1,000-NPC comparison,700 tics,1,000 survivors in both runs,
1280x720 Vulkan/60FPS cap,5% audio/unpaused background:

| Native renderer callback interval | Previous runtime | Final runtime |
| --- | ---: | ---: |
| Mean ms | 16.667 | 16.667 |
| p95 ms | 17.328 | 17.285 |
| p99 ms | 17.795 | 17.982 |
| Worst ms | 20.046 | 19.007 |

Both captured1,199 intervals. Wall duration of the700-tic phase was19,948/20,051ms
(polling uncertainty100ms). AI attacks/movement were disabled in this diagnostic;
production thermal scheduling remained active. PresentMon trace access was denied.
Callback cadence is not display presentation, GPU time, full campaign performance
or siege acceptance. The existing thermal emitter searches are unchanged; this
adapter adds only owner-local work. Raw records and configuration are in native/.

CA502-NPC-01 passed author review on2026-10-25. The agent inspected the live Spanish
overlay; physical Escape ended further UI input. The author subsequently accepted
the supplied test. F1 resets the diagnostic actors; F2 only prints current values.

Generic scenery/loose-object exposure, continuous actor brushing, historical
off-map exposure and household cleaning remain unfinished. Existing NPC physiology
pauses in unloaded maps. No NPC illness damage, new balance, art or map change is
introduced. This delivery does not complete #502 or V5.8.
